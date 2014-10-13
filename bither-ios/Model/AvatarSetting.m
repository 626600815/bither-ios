//
//  AvatarSetting.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "AvatarSetting.h"
#import "DialogProgress.h"
#import "FileUtil.h"
#import "BitherSetting.h"
#import "UIImageExt.h"
#import "UIViewController+SwipeRightToPop.h"

static Setting* avatarSetting;

@implementation AvatarSetting

+(Setting *)getAvatarSetting{
    if(!avatarSetting){
        UIImage *image=[UIImage imageNamed:@"avatar_button_icon"];
       
        AvatarSetting*  sAvatarSetting=[[AvatarSetting alloc] initWithName:NSLocalizedString(@"Set Avatar", nil) icon:image];
        __weak AvatarSetting* sself=sAvatarSetting;
        [sAvatarSetting setSelectBlock:^(UIViewController * controller){
            sself.controller=controller;
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Set Avatar", nil)
                                                                  delegate:sself                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"From Camera", nil),NSLocalizedString(@"From Gallery", nil),nil];
            
            actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        avatarSetting = sAvatarSetting;
    }
    return avatarSetting;
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        ImagePickerWithPhotoViewController *picker = [[ImagePickerWithPhotoViewController alloc] init];
    
        picker.cropDelegate = self;
        
        [self.controller presentViewController:picker animated:YES completion:nil];
    
    }else if(buttonIndex==1){
        ImagePickerWithCropViewController *picker = [[ImagePickerWithCropViewController alloc] init];
        picker.cropDelegate = self;
        [self.controller presentViewController:picker animated:YES completion:nil];
    
    }
}

#pragma mark - Process Album Photo from Image Pick
- (UIImage *)processAlbumPhoto:(NSDictionary *)info {
    return [info objectForKey:UIImagePickerControllerEditedImage];
}

#pragma mark - UIImagePicker Delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = [self processAlbumPhoto:info];
    __block UIImage * blockImage=image;
    DialogProgress *dialogProgrees=[[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dialogProgrees showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            long long timestmap=[[NSDate date] timeIntervalSince1970]*FORMAT_TIMESTAMP_INTERVAL;
            NSString* fileName=[NSString stringWithFormat:@"a%lld.jpg",timestmap];
            blockImage=[image scaleToSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)];
            NSString* uploadImageDir=[FileUtil getUploadAvatarDir];
            [FileUtil saveImage:[uploadImageDir stringByAppendingString:fileName] image:blockImage];
            NSString * avatartImageDir=[FileUtil getAvatarDir];
            [FileUtil saveImage:[avatartImageDir stringByAppendingString:fileName] image:blockImage];
            NSString * samllAvararImageDir=[FileUtil getSmallAvatarDir];
            UIImage * smallImage=[blockImage scaleToSize:CGSizeMake(SMALL_IMAGE_WIDTH, SMALL_IMAGE_WIDTH)];
            [FileUtil saveImage:[samllAvararImageDir stringByAppendingString:fileName] image:smallImage];
            [[UserDefaultsUtil instance] setUserAvatar:fileName];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dialogProgrees dismiss];
                if ([self.controller respondsToSelector:@selector(reload)]) {
                    [self.controller reload];
                }
            });
            
            
        });
    }];
    
}
-(UIImage*)getIcon{
    UIImage* image;
    NSString * avatarName=[[UserDefaultsUtil instance] getUserAvatar];
    if ([StringUtil isEmpty:avatarName]) {
        image=[UIImage imageNamed:@"avatar_button_icon"];
    }else{
        UIImage *broderImage=[UIImage imageNamed:@"avatar_button_icon_border"];
        NSString * samllAvatarDir=[FileUtil getSmallAvatarDir];
        image=[[UIImage alloc]initWithContentsOfFile:[samllAvatarDir stringByAppendingString:avatarName]];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(broderImage.size.width, broderImage.size.height), NO, 0);
        CGRect drawRect = CGRectMake(2, 2, broderImage.size.width-4, broderImage.size.height-4);
        [image drawInRect:drawRect];
        [broderImage drawInRect:CGRectMake(0, 0, broderImage.size.width, broderImage.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


@end

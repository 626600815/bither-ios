//
//  KeychainSetting.h
//  bither-ios
//
//  Created by ZhouQi on 14/11/22.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Setting.h"
#import "DialogPassword.h"
#import "DialogKeychainBackupDiff.h"

@interface KeychainSetting : Setting<DialogPasswordDelegate, DialogKeychainBackupDiffDelegate>

@property(nonatomic,strong) UIViewController * controller;

+(Setting *)getKeychainSetting;

@end

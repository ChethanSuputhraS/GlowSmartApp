//
//  SGFManager.m
//  SGFindSDK
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//


#import "BLEManager.h"
#import "Constant.h"

static BLEManager    *sharedManager    = nil;
//BLEManager    *sharedManager    = nil;

@interface BLEManager()
{
    NSMutableArray *disconnectedPeripherals;
    NSMutableArray *connectedPeripherals;
    NSMutableArray *peripheralsServices;

    CBCentralManager    *centralManager;
    BLEService * blutoothService;
    BOOL isVitDeviceFound;
    NSTimer * checkDeviceTimer;
    BOOL isAutoConnected;
}
@end

@implementation BLEManager
@synthesize delegate,foundDevices,connectedServices,centralManager,nonConnectArr, autoConnectArr;

#pragma mark- Self Class Methods
-(id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

#pragma mark --> Initilazie
-(void)initialize
{
    //  NSLog(@"bleManager initialized");
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:  @"CentralManagerIdentifier" }];
    centralManager.delegate = self;
    blutoothService.delegate = self;
    [foundDevices removeAllObjects];
    [nonConnectArr removeAllObjects];
    if(!foundDevices)foundDevices = [[NSMutableArray alloc] init];
    if(!nonConnectArr)nonConnectArr = [[NSMutableArray alloc] init];
    if(!connectedServices)connectedServices = [[NSMutableArray alloc] init];
    if(!disconnectedPeripherals)disconnectedPeripherals = [NSMutableArray new];
    [checkDeviceTimer invalidate];
    checkDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkDeviceWithmas) userInfo:nil repeats:YES];
}

-(void)checkDeviceWithmas
{
    isCheckforDashScann = YES;
    if (isVitDeviceFound)
    {
        isVitDeviceFound = NO;
    }
    else
    {
        updatedRSSI = 0;
    }
}
+ (BLEManager*)sharedManager
{
    if (!sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[BLEManager alloc] init];
        });
    }
    return sharedManager;
}
-(NSArray *)getLastConnected
{
    if (isConnectionIssue)
    {
        isConnectionIssue = NO;
    }
    return [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"]]];
}
#pragma mark- Scanning Method
-(void)startScan
{
    CBUUID * sUUID = [CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"];

    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}
#pragma mark - > Rescan Method
-(void) rescan
{
    centralManager.delegate = self;
    blutoothService.delegate = self;
    self.serviceDelegate = self;
    CBUUID * sUUID = [CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"];

    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,
                              nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}

#pragma mark - Stop Method
-(void)stopScan
{
    self.delegate = nil;
    self.serviceDelegate = nil;
    blutoothService.delegate = nil;
    blutoothService = nil;
    centralManager.delegate = nil;
//    [foundDevices removeAllObjects];
    [centralManager stopScan];
    [blutoothSearchTimer invalidate];
    
}

#pragma mark - Central manager delegate method stop
-(void)centralmanagerScanStop
{
    [centralManager stopScan];
}
#pragma mark - Connect Ble device
- (void) connectDevice:(CBPeripheral*)device{
    
    if (device == nil)
    {
        return;
    }
    else
    {//3.13.1 is live or testlgijt ?
        if ([disconnectedPeripherals containsObject:device])
        {
            [disconnectedPeripherals removeObject:device];
        }
        NSLog(@"2------------> Connect Device");
        [self connectPeripheral:device];
    }
}

#pragma mark - Disconenct Device
- (void)disconnectDevice:(CBPeripheral*)device
{
    if (device == nil) {
        return;
    }else{
        [self disconnectPeripheral:device];
    }
}

-(void)connectPeripheral:(CBPeripheral*)peripheral
{
    NSError *error;
    if (peripheral)
    {
        if (peripheral.state != CBPeripheralStateConnected)
        {
            [centralManager connectPeripheral:peripheral options:nil];
        }
        else
        {
            if(delegate)
            {
                [delegate didFailToConnectDevice:peripheral error:error];
            }
        }
    }
    else
    {
        if(delegate)
        {
            [delegate didFailToConnectDevice:peripheral error:error];
        }
    }
}

-(void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.delegate didDisconnectDevice:peripheral];
    if (peripheral)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            [centralManager cancelPeripheralConnection:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
        }
    }
}
-(void) updateBluetoothState
{
    [self centralManagerDidUpdateState:centralManager];
}
-(void) updateBleImageWithStatus:(BOOL)isConnected andPeripheral:(CBPeripheral*)peripheral
{
}
#pragma mark -  Search Timer Auto Connect
-(void)searchConnectedBluetooth:(NSTimer*)timer
{
    //    NSLog(@"its scanning");
    [self rescan];
}
#pragma mark Scan Sync Timer
-(void)scanDeviceSync:(NSTimer*)timer
{
}
#pragma mark - CBCentralManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
    /*----Here we can come to know bluethooth state----*/
    [blutoothSearchTimer invalidate];
    blutoothSearchTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchConnectedBluetooth:) userInfo:nil repeats:YES];
    
    switch (central.state)
    {
        case CBPeripheralManagerStateUnknown:
            //The current state of the peripheral manager is unknown; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The current state of the peripheral manager is unknown; an update is imminent."];
            
            break;
        case CBPeripheralManagerStateUnauthorized:
            //The app is not authorized to use the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The app is not authorized to use the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStateResetting:
            //The connection with the system service was momentarily lost; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The connection with the system service was momentarily lost; an update is imminent."];
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            //Bluetooth is currently powered off"
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered off."];
            
            break;
        case CBPeripheralManagerStateUnsupported:
            //The platform doesn't support the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The platform doesn't support the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStatePoweredOn:
            //Bluetooth is currently powered on and is available to use.
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered on and is available to use."];
            break;
    }
}

#pragma mark - Finding Device with in Range
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //  NSLog(@"peripherals==%@",peripherals);
}

#pragma mark - Discover all devices here
/*-----------if device is in range we can find in this method--------*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * checkNameStr = [NSString stringWithFormat:@"%@",peripheral.name];
    if ([checkNameStr rangeOfString:@"Vithamas"].location != NSNotFound && ![checkNameStr isEqualToString:@"Vithamas’s iPhone"] && ![checkNameStr isEqualToString:@"Vithamas MacBook Air"])
    {//
        
        NSString * strConnect = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataIsConnectable"]];
//        NSLog(@"Here is Found Peripheral===%@ and type=%@",peripheral,strConnect);
        if ([strConnect isEqualToString:@"1"])
        {
            if (peripheral.state == CBPeripheralStateDisconnected ||  peripheral.state == CBPeripheralStateConnected)
            {
                if (autoConnectArr == nil || autoConnectArr.count == 0)
                {
                    autoConnectArr = [[NSMutableArray alloc] init];
                }
                if (![autoConnectArr containsObject:peripheral])
                {
                    [autoConnectArr addObject:peripheral];
                }
                else
                {
                    NSInteger foundIndex = [autoConnectArr indexOfObject:peripheral];
                    if (foundIndex != NSNotFound)
                    {
                        if ([autoConnectArr count] > foundIndex)
                        {
                            [autoConnectArr replaceObjectAtIndex:foundIndex withObject:peripheral];
                        }
                    }
                }
                if (peripheral.state == CBPeripheralStateConnected)
                {
                    globalPeripheral = peripheral;
                }
                if (isNonConnectScanning)
                {
                    if (globalPeripheral.state != CBPeripheralStateConnected)
                    {
//                        [[BLEManager sharedManager] connectDevice:peripheral];
                    }
                }
            }
        }
        else
        {
            if (peripheral.state == CBPeripheralStateConnected)
            {
                if (autoConnectArr == nil || autoConnectArr.count == 0)
                {
                    autoConnectArr = [[NSMutableArray alloc] init];
                }
                if (![autoConnectArr containsObject:peripheral])
                {
                    [autoConnectArr addObject:peripheral];
                }
                else
                {
                    NSInteger foundIndex = [autoConnectArr indexOfObject:peripheral];
                    if (foundIndex != NSNotFound)
                    {
                        if ([autoConnectArr count] > foundIndex)
                        {
                            [autoConnectArr replaceObjectAtIndex:foundIndex withObject:peripheral];
                        }
                    }
                }
                globalPeripheral = peripheral;
                if (isNonConnectScanning)
                {
                    if (globalPeripheral.state != CBPeripheralStateConnected)
                    {
//                        [[BLEManager sharedManager] connectDevice:peripheral];
                    }
                }
            }
        }

        if (isScanCheckforDashboard)
        {
            if (isCheckforDashScann)
            {
                NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
                NSString * strManufac = [NSString stringWithFormat:@"%@",nameData.debugDescription];
                [self UpdateBrightnessonDashboard:strManufac];
            }
        }
        else
        {
            if (isViewWillAppeared)
            {
                NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
                NSString * strManufac = [NSString stringWithFormat:@"%@",nameData.debugDescription];
                [self UpdateBrightnessonDashboard:strManufac];
                isViewWillAppeared = false;
            }
        }
        isVitDeviceFound = YES;
        updatedRSSI = [RSSI integerValue];
//        NSLog(@"1------------> %@",strConnect);

        if (isDashScanning)
        {
            [self SendCallbackforDashboardDeleteRequest:peripheral withData:advertisementData];
        }
        else if (isOnAddGroup)
        {
            [self SendCallBackforAddingGroups:peripheral withData:advertisementData];
        }
        else if (isNonConnectScanning)
        {
//            NSLog(@" ====>Start COnnection Request Device isconnectable=%@",advertisementData);
            [self SendCallbackforScanningRequest:peripheral withData:advertisementData];
        }
        else if (isfromBridge)
        {
            if (isSearchingfromFactory)
            {
                [self ScanforFactoryResetTest:peripheral withData:advertisementData];
            }
            else
            {
                NSString * strConnect = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataIsConnectable"]];
                if ([strConnect isEqualToString:@"1"])
                {
                    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];

                    NSString * strAdvData = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
                    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@">" withString:@""];
                    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    
                    if ([strAdvData length] >15)
                    {
                        NSArray * checkArr = [strAdvData componentsSeparatedByString:@"0a00"];
                        if ([checkArr count]>1)
                        {
                            NSString * addString = [checkArr objectAtIndex:1];
                            if ([addString length] >11)
                            {
                                NSRange rangeFirst = NSMakeRange(0, 12);
                                NSString * strFinalAddress = [[addString substringWithRange:rangeFirst] uppercaseString];
                                if ([[foundDevices valueForKey:@"address"] containsObject:strFinalAddress])
                                {
                                    NSInteger foundIndex = [[foundDevices valueForKey:@"address"] indexOfObject:strFinalAddress];
                                    if (foundIndex != NSNotFound)
                                    {
                                        if ([foundDevices count] > foundIndex)
                                        {
                                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                            [dict setObject:peripheral forKey:@"peripheral"];
                                            [dict setObject:strFinalAddress forKey:@"address"];
                                            [foundDevices replaceObjectAtIndex:foundIndex withObject:dict];
                                        }
                                    }
                                }
                                else
                                {
                                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                    [dict setObject:peripheral forKey:@"peripheral"];
                                    [dict setObject:strFinalAddress forKey:@"address"];
                                    [foundDevices addObject:dict];
                                }
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallNotificationforNonConnectforAdd" object:peripheral userInfo:advertisementData];
                    }
                }
            }
        }
    }
    else
    {
    }
}
-(void)SendCallBackforAddingGroups:(CBPeripheral *)peripheral withData:(NSDictionary *)advertisementData
{
    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    if ([nameData length] > 10)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
        NSRange rangeFirst = NSMakeRange(1, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"0a00"])
        {
            rangeFirst = NSMakeRange(5, [nameString length]-5);
            NSString * kpstr = [nameString substringWithRange:rangeFirst];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            NSString * strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
            NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
            NSData * updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            if ([strDecrypted length]==[kpstr length])
            {
                NSRange rangeCheck = NSMakeRange([strDecrypted length]-4, 4);
                NSString * strOpCodeCheck = [strDecrypted substringWithRange:rangeCheck];
                if ([strOpCodeCheck isEqualToString:@"0b00"])
                {
                    NSString * strScanNotify = [NSString stringWithFormat:@"CallNotificationforAddGroups"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:strScanNotify object:strDecrypted];
                }
                else if([strOpCodeCheck isEqualToString:@"0900"])
                {
                    NSString * strScanNotify = [NSString stringWithFormat:@"CallNotificationforAddGroups"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:strScanNotify object:strDecrypted];
                }
            }
        }
    }
}

-(void)SendCallbackforDashboardDeleteRequest:(CBPeripheral *)peripheral withData:(NSDictionary *)advertisementData
{
    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    //    NSLog(@"ADVERTISEDATA=%@",advertisementData );
    
    if ([nameData length] >= 9)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
        NSRange rangeFirst = NSMakeRange(1, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"0a00"])
        {
            rangeFirst = NSMakeRange(5, [nameString length]-5);
            NSString * kpstr = [nameString substringWithRange:rangeFirst];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
//            NSLog(@"LOGO=%@",kpstr);
            NSString * strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
            NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
            NSData * updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            if ([strDecrypted length]==[kpstr length])
            {
                NSRange rangeCheck = NSMakeRange([strDecrypted length]-4, 4);
                NSString * strOpCodeCheck = [strDecrypted substringWithRange:rangeCheck];
                if ([strOpCodeCheck isEqualToString:@"0b00"])
                {
                    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDash%@",strGlogalNotify];
                    [[NSNotificationCenter defaultCenter] postNotificationName:strScanNotify object:strDecrypted];
                }
                else if([strOpCodeCheck isEqualToString:@"3800"])
                {
                    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDash%@",strGlogalNotify];
                    [[NSNotificationCenter defaultCenter] postNotificationName:strScanNotify object:strDecrypted];
                }
            }
        }
    }
}
-(void)SendCallbackforScanningRequest:(CBPeripheral *)peripheral withData:(NSDictionary *)advertisementData
{
    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    if ([nameData length] >= 9)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
//        NSLog(@"=====================================================================Degub=%@  & =====descroption=%@",nameString, nameData.description);
        NSRange rangeFirst = NSMakeRange(1, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"0a00"])
        {
            rangeFirst = NSMakeRange(5, [nameString length]-5);
            NSString * kpstr = [nameString substringWithRange:rangeFirst];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            NSString * strAddressFound = @"NA";
            NSString * strDestID = [kpstr substringWithRange:NSMakeRange(6,4)];
            NSString * strKeys;
            
            if ([kpstr length] >=42)
            {
                NSLog(@"HERE IT IS====>>>>>>>>>>>>>>>%@",kpstr);
                return;
            }
            if ([strDestID isEqualToString:@"0000"])
            {
                strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"]];
//                NSLog(@"VDKKKKKKKKKKKKK====>>>>>>>>>>>>>>>%@",kpstr);

            }
            else
            {
                strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
//                NSLog(@"PASSSSKKEEYYYY====>>>>>>>>>>>>>>>%@",kpstr);
            }
            
            NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
            NSData * updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            nameString = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            if ([strDecrypted length]>=34)
            {
                NSRange rangeCheck = NSMakeRange(18, 4);
                NSString * strOpCodeCheck = [strDecrypted substringWithRange:rangeCheck];
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

                if ([strOpCodeCheck isEqualToString:@"1700"] || [strOpCodeCheck isEqualToString:@"3000"])
                {
                    NSRange range71 = NSMakeRange(22, 12);
                    strAddressFound = [[strDecrypted substringWithRange:range71] uppercaseString];
                    if ([[nonConnectArr valueForKey:@"address"] containsObject:strAddressFound])
                    {
                        NSInteger foundIndex = [[nonConnectArr valueForKey:@"address"] indexOfObject:strAddressFound];
                        if (foundIndex != NSNotFound)
                        {
                            if ([nonConnectArr count] > foundIndex)
                            {
                                if ([[[nonConnectArr objectAtIndex:foundIndex] valueForKey:@"Manufac"] length]>20)
                                {
                                    [dict setObject:peripheral forKey:@"peripheral"];
                                    [dict setObject:nameString forKey:@"Manufac"];
                                    [dict setObject:strAddressFound forKey:@"address"];
                                    
                                    if (![strOpCodeCheck isEqualToString:@"1700"])
                                    {
                                        [dict setObject:@"1" forKey:@"isAdded"];
                                    }
                                    else
                                    {
                                        [dict setObject:@"2" forKey:@"isAdded"];
                                    }
                                    [nonConnectArr replaceObjectAtIndex:foundIndex withObject:dict];
                                }
                            }
                        }
                    }
                    else
                    {
//                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:peripheral forKey:@"peripheral"];
                        [dict setObject:nameString forKey:@"Manufac"];
                        [dict setObject:strAddressFound forKey:@"address"];
                        if (![strOpCodeCheck isEqualToString:@"1700"])
                        {
                            [dict setObject:@"1" forKey:@"isAdded"];
                        }
                        else
                        {
                            [dict setObject:@"2" forKey:@"isAdded"];
                        }
                        [nonConnectArr addObject:dict];
                    }
                    if ([strSelectedAddress isEqualToString:[strAddressFound uppercaseString]])
                    {
                        if ([strOpCodeCheck isEqualToString:@"1700"])
                        {
                            if(delegate)
                            {
                                [self.delegate DeviceAddedSuccessfully:dict];
                            }
                            strSelectedAddress = @"NA";
                        }
                    }
                }
            }
        }
    }
    
    if ([nameData length]>0)
    {
        [delegate DeviceScannedSuccessfully:advertisementData];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallNotificationforNonConnectforAdd" object:peripheral userInfo:advertisementData];
    }
}
-(void)ScanforFactoryResetTest:(CBPeripheral *)peripheral withData:(NSDictionary *)advertisementData
{
    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    if ([nameData length] >= 9)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
        NSRange rangeFirst = NSMakeRange(1, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"0a00"])
        {
            rangeFirst = NSMakeRange(5, [nameString length]-5);
            NSString * kpstr = [nameString substringWithRange:rangeFirst];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            NSString * str1 = @"NA";
            NSString * strDestID = [kpstr substringWithRange:NSMakeRange(6,4)];
            NSString * strKeys;
            
            if ([strDestID isEqualToString:@"0000"])
            {
                strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"]];
            }
            else
            {
                strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
            }
            NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
            NSData*updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            nameString = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            if ([strDecrypted length]>=34)
            {
                NSRange rangeCheck = NSMakeRange(18, 4);
                NSString * strOpCodeCheck = [strDecrypted substringWithRange:rangeCheck];
                if ([strOpCodeCheck isEqualToString:@"3000"])
                {
                    NSRange range71 = NSMakeRange(22, 12);
                    str1 = [strDecrypted substringWithRange:range71];
                    if ([str1 isEqualToString:strSelectedAddress])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetSuccessPopup" object:peripheral];
                    }
                }
            }
        }
    }
    
    if ([nameData length]>0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallNotificationforNonConnectforAdd" object:peripheral userInfo:advertisementData];
    }
}
-(void)SendCallbackforBridgeConnection:(CBPeripheral  *)peripheral withData:(NSDictionary *)advertisementData withConnectStr:(NSString *)connStr withRSSI:(NSNumber *)RSSSI
{
    if ([connStr isEqualToString:@"1"])
    {
        NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
        if ([nameData length]>0)
        {
            NSString *nameString = [NSString stringWithFormat:@"%@",nameData.debugDescription]; //this works
            if ([[foundDevices valueForKey:@"peripheral"] containsObject:peripheral])
            {
                if(![peripheral.name isEqualToString:@"(null)"] && ![peripheral.name isEqual:[NSNull null]] && [peripheral.name length]>0)
                {
                    NSInteger foundIndex = [[foundDevices valueForKey:@"peripheral"] indexOfObject:peripheral];
                    if (foundIndex != NSNotFound)
                    {
                        if ([foundDevices count] > foundIndex)
                        {
                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                            [dict setObject:peripheral forKey:@"peripheral"];
                            [dict setObject:nameString forKey:@"Manufac"];
                            [foundDevices replaceObjectAtIndex:foundIndex withObject:dict];
                        }
                    }
                }
            }
            else
            {
                if(![peripheral.name isEqualToString:@"(null)"] && ![peripheral.name isEqual:[NSNull null]] && [peripheral.name length]>0)
                {
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:peripheral forKey:@"peripheral"];
                    [dict setObject:nameString forKey:@"Manufac"];
                    [foundDevices addObject:dict];
                }
            }
        }
    }
    
}
-(void)UpdateBrightnessonDashboard:(NSString *)strManufac
{
    if ([strManufac length] > 10)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",strManufac]; //this works
        NSRange rangeFirst = NSMakeRange(1, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"0a00"])
        {
            rangeFirst = NSMakeRange(5, [nameString length]-5);
            NSString * kpstr = [nameString substringWithRange:rangeFirst];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            NSString * strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
            
            NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
            NSData * updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData.debugDescription];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            if ([strDecrypted length]>=34)
            {
                NSRange rangeCheck = NSMakeRange([strDecrypted length]-16, 4);
                NSString * strOpCodeCheck = [strDecrypted substringWithRange:rangeCheck];
                if ([strOpCodeCheck isEqualToString:@"1800"])
                {
                    NSString * strScanNotify = [NSString stringWithFormat:@"SendCallbackforDashScanning"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:strScanNotify object:strDecrypted];
                    isCheckforDashScann = NO;
                }
            }
            
        }
    }
}
#pragma mark - > Resttore state of devices
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSArray *peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    if (peripherals.count>0)
    {
        for (CBPeripheral *p in peripherals)
        {
            if (p.state != CBPeripheralStateConnected)
            {
                //[self connectPeripheral:p];
            }
        }
    }
}

#pragma mark - Fail to connect device
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*---This method will call if failed to connect device-----*/
    if(delegate)[delegate didFailToConnectDevice:peripheral error:error];
}

- (void)discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;
{
    
}
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
{
    
}
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
{
    
}


#pragma mark - Connect Delegate method
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"3------------> didConnectPeripheral Device");
    NSMutableArray * tmpArr = [[BLEManager sharedManager] foundDevices];
    if ([[tmpArr valueForKey:@"peripheral"] containsObject:peripheral])
    {
        NSInteger  foudIndex = [[tmpArr valueForKey:@"peripheral"] indexOfObject:peripheral];
        if (foudIndex != NSNotFound)
        {
            if ([tmpArr count] > foudIndex)
            {
                NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
                NSString * strName = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"name"];
                NSString * strAddress = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"address"];
                NSLog(@"3------------><-------------33333===>%@",strAddress);

                if (![[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                {
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setValue:strCurrentIdentifier forKey:@"identifier"];
                    [dict setValue:peripheral forKey:@"peripheral"];
                    [dict setValue:strName forKey:@"name"];
                    [dict setValue:strAddress forKey:@"address"];
                    NSLog(@"3------------><-------------3===>%@",dict);
                    [arrGlobalDevices addObject:dict];
                }
            }
        }
    }

    /*-------This method will call after succesfully device Ble device connect-----*/
    peripheral.delegate = self;
    
    bleConnectStatusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:currentScreen object:nil];
    if (peripheral.services)
    {
        [self peripheral:peripheral didDiscoverServices:nil];
    }
    else
    {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"]]];
    }
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"4------------> didDiscoverServices Device=%@",peripheral.services);

    BOOL gotService = NO;
    for(CBService* svc in peripheral.services)
    {
        gotService = YES;
//        NSLog(@"service=%@",svc);
        if(svc.characteristics)
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        else
            [peripheral discoverCharacteristics:nil forService:svc]; //need to discover characteristics
    }
    if (gotService == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHud" object:nil];
        [self disconnectDevice:peripheral];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    globalPeripheral = peripheral;
    NSLog(@"5------------> didDiscoverCharacteristicsForService Device");

    NSLog(@"------>Global Peripheral Connected<--------");
    if (isfromBridge)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidConnectNotificationBridge" object:peripheral];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidConnectNotification" object:peripheral];
        [delegate DeviceConnectedSuccessfully:peripheral];
    }
    if (isFromFactoryRest)
    {
//        [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
//        [[BLEService sharedInstance] readAuthValuefromManager:peripheral];
//        [self performSelector:@selector(sendFactoryReset) withObject:nil afterDelay:1];
    }
    else
    {
        [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
        [[BLEService sharedInstance] readAuthValuefromManager:peripheral];
    }
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];//TTL
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2]; //Sequence Count
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2]; //Source ID for mobile
        
        NSInteger int4 = [@"0" integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2]; //Destination ID
        
        NSInteger int5 = [@"1234" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2]; //
        
        NSInteger intOpCode = [@"96" integerValue];
        NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:2]; //Opcode
        
        NSInteger intDay = [self getDayInteger];
        NSData * dataDay = [[NSData alloc] initWithBytes:&intDay length:1]; //Dat
        
        NSInteger intHour = hour;
        NSData * dataHour = [[NSData alloc] initWithBytes:&intHour length:1]; //Hour
        
        NSInteger intMin = minute;
        NSData * dataMin = [[NSData alloc] initWithBytes:&intMin length:1]; //Minute
        
        NSMutableData * completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:data5];
        [completeData appendData:dataOpcode];
        [completeData appendData:dataDay];
        [completeData appendData:dataHour];
        [completeData appendData:dataMin];
        
        
        if (![currentScreen isEqualToString:@"AddDevice"])
        {
            [[BLEService sharedInstance] writeValuetoDeviceMsg:completeData with:globalPeripheral];
            [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        
        isTimeSetSuccess = YES;
//        NSLog(@"Time set");
    }
}
-(void)sendFactoryReset
{
    [[BLEService sharedInstance] sendNotifications:globalPeripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
    [[BLEService sharedInstance] readAuthValuefromManager:globalPeripheral];
    //    [self performSelector:@selector(finalReset) withObject:nil afterDelay:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowResetNotification" object:nil];
}
-(void)finalReset
{
    [[BLEService sharedInstance] sendNotifications:globalPeripheral withType:NO withUUID:@"0003D100-AB00-11E1-9B23-00025B00A5A5"];
    [[BLEService sharedInstance] readFactoryResetValue:globalPeripheral];
}
-(NSInteger)getDayInteger
{
    NSInteger dayInt = 1;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
    
    if ([dayName isEqualToString:@"Sunday"])
    {
        dayInt= 1;
    }
    else if ([dayName isEqualToString:@"Monday"])
    {
        dayInt =2;
    }
    else if ([dayName isEqualToString:@"Tuesday"])
    {
        dayInt=3;
    }
    else if ([dayName isEqualToString:@"wednesday"])
    {
        dayInt=4;
    }
    else if ([dayName isEqualToString:@"Thursday"])
    {
        dayInt=5;
    }
    else if ([dayName isEqualToString:@"Friday"])
    {
        dayInt =6;
    }
    else if ([dayName isEqualToString:@"Saturday"])
    {
        dayInt=7;
    }
    else
    {
        dayInt=7;
    }
//        NSLog(@"Day=%@",[NSString stringWithFormat:@"%@",dayName]);
    return dayInt;
}
#pragma mark - Disconnect Ble Device
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
    NSLog(@"9 ------------> didDisconnectPeripheral Device");

    bleConnectStatusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    
    if ([[arrGlobalDevices valueForKey:@"peripheral"] containsObject:peripheral])
    {
        NSInteger foundIndex = [[arrGlobalDevices valueForKey:@"peripheral"] indexOfObject:peripheral];
        if (foundIndex != NSNotFound)
        {
            if (arrGlobalDevices.count > foundIndex)
            {
                [arrGlobalDevices removeObjectAtIndex:foundIndex];
            }
        }
    }

    if (isfromBridge)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotificationBridge" object:peripheral];
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
        [delegate DeviceDiscConnectedSuccessfully:peripheral];
    }
}
-(void)timeOutConnection
{
    [APP_DELEGATE endHudProcess];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEConnectionErrorPopup" object:nil];
}
@end
//    kCBAdvDataManufacturerData = <0a00640b 00009059 22590161 00007f0c 09fb0069 00>;
//0a00 0002 32ac 6057 26
//  329a00cc090000ea761800010001787878
//<32 d401 0000 0000 dffb 3000 df 1dc06f04 a80600>
//<CBPeripheral: 0x282872da0, identifier = F2AE977D-50AE-73E4-6741-81629220E0F7, name = Vithamas AC Stp, state = disconnected> and type=1
//<CBPeripheral: 0x282872da0, identifier = F2AE977D-50AE-73E4-6741-81629220E0F7, name = Vithamas AC Stp, state = disconnected> and type=0

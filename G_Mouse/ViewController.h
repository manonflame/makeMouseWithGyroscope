//
//  ViewController.h
//  G_Mouse
//
//  Created by 민경준 on 2017. 5. 22..₩
//  Copyright © 2017년 민경준. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define TRANSFER_SERVICE_UUID           @"1A2B"
#define TRANSFER_CHARACTERISTIC_UUID    @"3C4D"


@interface ViewController : UIViewController<CBPeripheralDelegate>{
    //왼쪽 더블탭 트리플탭 변수
    UITapGestureRecognizer *doubleLeftTapGestureRecognizer;
    UITapGestureRecognizer *tripleLeftTapGestureRecognizer;
    
    //오른쪽 더플탭 트리플탭 변수
    UITapGestureRecognizer *doubleRightTapGestureRecognizer;
    UITapGestureRecognizer *tripleRightTapGestureRecognizer;
    
    //자이로 모션 관리자
    CMMotionManager *manager;
    
    //자이로 센서 변수
    float x;
    float y;
    
    //민감도 설정
    float sensitivity;
    
    //블루투스 uuid
    CBUUID *uuid;
}


@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;

@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) IBOutlet UISlider *DPISlider;

- (IBAction)leftButtonClick:(id)sender;  //touch up inside
- (IBAction)leftButtonDrag:(id)sender;   //touch down

- (IBAction)rightButtonClick:(id)sender; //touch up inside
- (IBAction)rightButtonDrag:(id)sender;  //touch down

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic;
- (void)sendData:(NSString *)message;
- (void)startAdvertising:(NSDictionary<NSString *,id> *)advertisementData;
- (IBAction)ChangeDPI:(id)sender;



@end


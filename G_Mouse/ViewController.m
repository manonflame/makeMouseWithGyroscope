//
//  ViewController.m
//  G_Mouse
//
//  Created by 민경준 on 2017. 5. 22..
//  Copyright © 2017년 민경준. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()

@end

@implementation ViewController
@synthesize leftButton, rightButton, DPISlider;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //자이로 센서 객체 생성 및 주기설정
    manager = [[CMMotionManager alloc]init];
    manager.deviceMotionUpdateInterval = 0.1; //10Hz
    sensitivity = 10;
    
    NSLog(@"확인");
    //블루투스 관련 인스턴스 생성
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    CBUUID *uuid = [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID];
    NSArray *uuids = @[uuid];
    NSDictionary *info = @{CBAdvertisementDataServiceDataKey: uuids,
                           CBAdvertisementDataLocalNameKey:@"nil"};
    NSLog(@"블루투스 게시 시작");
    [_peripheralManager startAdvertising:info];
    
    
    x,y= 0;
    
    
    if([manager isGyroAvailable]){
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion* motion, NSError* error){
            CMRotationRate rot = motion.rotationRate;
            
            
            //자이로 센서의 x축 기준 회전이 화면상의 y값을 변화
            x -= sensitivity*rot.z;
            
            //자이로 센서의 z축 기준 회전이 화면상의 x값을 변화
            y -= sensitivity*rot.x;
            
            
            
            NSLog(@" 현재의 마우스 좌표 ( %+3.5f, %+3.5f )", x, y);
            NSString* msg = [NSString stringWithFormat:@"x:%f y:%f",100*x ,100*y];
            NSLog(@"x:%f y:%f",x ,y);
            //마우스의 x좌표와 y좌표를 전송
            [self sendData:msg];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendData:(NSString *)message{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    BOOL didSend = [_peripheralManager updateValue:data forCharacteristic:_transferCharacteristic onSubscribedCentrals:nil];
    if(didSend){
        NSLog(@"Sent : %@",message);
    }
}



- (IBAction)leftButtonClick:(id)sender {
    
    //왼쪽 더블 클릭 인식을 위한 GestureRecognizer 생성 - handleLeftDoubleTapGesture에서 동작 내용 구현
    doubleLeftTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftDoubleTapGesture:)];
    //왼쪽 트리플 클릭 인식을 위한 GestureRecognizer 생성 - handleLeftTripleleTapGesture에서 동작 내용 구현
    tripleLeftTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftTripleTapGesture:)];
    
    //왼쪽 더블 클릭 인식을 위한 GestureRecognizer 설정 : 횟수 2회
    doubleLeftTapGestureRecognizer.numberOfTapsRequired = 2;
    //왼쪽 트리플 클릭 인식을 위한 GestureRecognizer 설정 : 횟수 3회
    tripleLeftTapGestureRecognizer.numberOfTapsRequired = 3;
    
    //더블 클릭은 트리플 클릭이 인식될 시에 실패로 규정함
    [doubleLeftTapGestureRecognizer requireGestureRecognizerToFail:tripleLeftTapGestureRecognizer];
    
    //현재 뷰(UIButton)에 생성한 제스쳐 인식자들을 추가함
    [self.view addGestureRecognizer:doubleLeftTapGestureRecognizer];
    [self.view addGestureRecognizer:tripleLeftTapGestureRecognizer];
    
    
    NSLog(@"왼쪽 - 싱글 탭이 인식되었습니다.");
    NSString* msg = [NSString stringWithFormat:@"LS"];
    //동작에 의한 신호를 전송
    [self sendData:msg];
}

- (IBAction)leftButtonDrag:(id)sender {
    NSLog(@"왼쪽 - 드래그 탭이 인식되었습니다.");
    NSString* msg = [NSString stringWithFormat:@"LG"];
    //동작에 의한 신호를 전송
    [self sendData:msg];

}

- (IBAction)rightButtonClick:(id)sender {
    //오른쪽 더블 클릭 인식을 위한 GestureRecognizer 생성 - handleRightDoubleTapGesture에서 동작 내용 구현
    doubleRightTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightDoubleTapGesture:)];
    //오른쪽 트리플 클릭 인식을 위한 GestureRecognizer 생성 - handleRightTripleTapGesture에서 동작 내용 구현
    tripleRightTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightTripleTapGesture:)];
    
    //오른쪽 더블 클릭 인식을 위한 GestureRecognizer 설정 : 횟수 2회
    doubleRightTapGestureRecognizer.numberOfTapsRequired = 2;
    //오른쪽 더블 클릭 인식을 위한 GestureRecognizer 설정 : 횟수 3회
    tripleRightTapGestureRecognizer.numberOfTapsRequired = 3;
    
    //더블 클릭은 트리플 클릭이 인식될 시에 실패로 규정함
    [doubleRightTapGestureRecognizer requireGestureRecognizerToFail:tripleRightTapGestureRecognizer];
    
    //현재 뷰(UIButton)에 생성한 제스쳐 인식자들을 추가함
    [self.view addGestureRecognizer:doubleRightTapGestureRecognizer];
    [self.view addGestureRecognizer:tripleRightTapGestureRecognizer];
    
    
    NSLog(@"오른쪽 - 싱글 탭이 인식되었습니다.");
    NSString* msg = [NSString stringWithFormat:@"RS"];
    //동작에 의한 신호를 전송
    [self sendData:msg];
}

- (IBAction)rightButtonDrag:(id)sender {
    NSLog(@"오른쪽 - 드래그 탭이 인식되었습니다.");
    NSString* msg = [NSString stringWithFormat:@"RG"];
    //동작에 의한 신호를 전송
    [self sendData:msg];

}



//왼쪽 더블 클릭 : doubleLeftTapGestureRecognizer가 인식될 시 작동 방식의 구현
- (void)handleLeftDoubleTapGesture:(UITapGestureRecognizer *)sender{
    if(doubleLeftTapGestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"왼쪽 - 더블 탭이 인식되었습니다.");
        NSString* msg = [NSString stringWithFormat:@"LD"];
        [self sendData:msg];
    }
}

//왼쪽 트리플 클릭 : handleLeftTripleTapGesture가 인식될 시 작동 방식의 구현
- (void)handleLeftTripleTapGesture:(UITapGestureRecognizer *)sender{
    if(tripleLeftTapGestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"왼쪽 - 트리플 탭이 인식되었습니다.");
        NSString* msg = [NSString stringWithFormat:@"LT"];
        [self sendData:msg];
    }
}


//오른쪽 더블 클릭 : handleRightDoubleTapGesture가 인식될 시 작동 방식의 구현
- (void)handleRightDoubleTapGesture:(UITapGestureRecognizer *)sender{
    if(doubleRightTapGestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"오른쪽 - 더블 탭이 인식되었습니다.");
        NSString* msg = [NSString stringWithFormat:@"RD"];
        [self sendData:msg];
    }
}

//오른쪽 트리플 클릭 : handleRightTripleTapGesture가 인식될 시 작동 방식의 구현
-(void)handleRightTripleTapGesture:(UITapGestureRecognizer *)sender{
    if(tripleRightTapGestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"오른쪽 - 트리플 탭이 인식되었습니다.");
        NSString* msg = [NSString stringWithFormat:@"RT"];
        [self sendData:msg];
    }
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    CBManagerState state = peripheral.state;
    
    if(state != CBManagerStatePoweredOn) {
        NSLog(@"peripheralManagerDidUpdateState error = %ld",state);
    }
    else{
        NSLog(@"bluetooth on ");
        CBUUID *uuidService = [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID];
        CBUUID *uuidCharacteristic = [CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID];
        
        
        CBCharacteristicProperties porperties = CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify;
        CBAttributePermissions permissions = CBAttributePermissionsReadable | CBAttributePermissionsWriteable;
        
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:uuidCharacteristic properties:porperties value:nil permissions:permissions];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:uuidService primary:YES];
        transferService.characteristics = @[_transferCharacteristic];
        
        [_peripheralManager addService:transferService];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    
    NSString *hello = [NSString stringWithFormat:@"connected"];
    
    [self sendData:hello];
    NSLog(@"start talking check:");
}






- (IBAction)ChangeDPI:(id)sender {
    sensitivity = DPISlider.value;
}
@end

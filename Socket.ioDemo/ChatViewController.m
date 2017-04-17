//
//  ChatViewController.m
//  Socket.ioDemo
//
//  Created by lottak_mac2 on 16/9/20.
//  Copyright © 2016年 com.lottak. All rights reserved.
//
@import SocketIO;
#import "ChatViewController.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"

@interface ChatViewController ()<SocketIODelegate,UITableViewDelegate,UITableViewDataSource> {
    SocketIO *_socketIO;
    UITableView *_tableView;
    NSMutableArray<NSDictionary*> *_dataArr;
    SocketIOClient* socket;
}

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *userName = [NSString stringWithFormat:@"%d号用户",arc4random()%100 + 1];
    self.title = userName;
//    [_socketIO connectToHost:@"localhost" onPort:3000];//连接
    [self connect];
    _dataArr = [@[] mutableCopy];
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUser:)],[[UIBarButtonItem alloc]initWithTitle:@"发" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage:)]];
    [_socketIO sendEvent:@"adduser" withData:userName];//添加用户
    // Do any additional setup after loading the view.
}

- (void)connect {
    NSURL* url = [[NSURL alloc] initWithString:@"http://ddcc.me:3000"];
     socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];

    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];
   

    [socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];

        [[socket emitWithAck:@"canUpdate" with:@[@(cur)]] timingOutAfter:0 callback:^(NSArray* data) {
            [socket emit:@"update" with:@[@{@"amount": @(cur + 2.50)}]];
        }];

        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];
    [socket on:@"typing" callback:^(NSArray * _Nonnull a, SocketAckEmitter *d) {
        NSLog(@"%@ , %@",a,d);
    }];
    
    [socket on:@"new message" callback:^(NSArray * _Nonnull a, SocketAckEmitter * _Nonnull b) {
        NSLog(@" new message %@ , %@",a,b);
        [_dataArr addObject:a[0]];
        [_tableView reloadData];


    }];

    [socket connect];

}

- (void)addUser:(UIBarButtonItem*)item {
    [self.navigationController pushViewController:[ChatViewController new] animated:YES];
}
- (void)sendMessage:(UIBarButtonItem*)item {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"输入消息内容" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入聊天内容...";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *message = [alertVC.textFields[0] text];
//        [socket sendEvent:@"sendchat" withData:message];//发送消息
        [socket emit:@"new message" with: [NSArray arrayWithObjects:message, message, nil]];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@说:",[_dataArr[indexPath.row] valueForKey:@"username"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[_dataArr[indexPath.row] valueForKey:@"message"]];
    return cell;
}
#pragma mark -- SocketIODelegate
- (void) socketIODidConnect:(SocketIO *)socket {
    
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    
}
- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    
}
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    
}
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    if([packet.name isEqualToString:@"updatechat"]) {
//        [_dataArr addObject:@{packet.args[0]:packet.args[1]}];
        [_tableView reloadData];
    }
}
- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    
}

@end

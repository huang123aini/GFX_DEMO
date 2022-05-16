//
//  ViewController.m
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#import "ViewController.h"
#include "OpenGLESView.h"
@interface ViewController ()
{
    OpenGLESView* opengl_view;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    opengl_view = [[OpenGLESView alloc]  initWithFrame:self.view.frame];
    [self.view addSubview: opengl_view];
}

@end

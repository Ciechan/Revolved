//
//  RVExportViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 27.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVExportViewController.h"
#import "RVColorProvider.h"
#import "RVModelManager.h"
#import "RVSTLExporter.h"
#import "RVOBJExporter.h"

#import "SSZipArchive.h"

@interface RVExportViewController () <UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIControl *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *stlButton;
@property (weak, nonatomic) IBOutlet UIButton *objButton;
@property (weak, nonatomic) IBOutlet UIButton *rvlvdButton;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation RVExportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stlButton.exclusiveTouch = YES;
    self.objButton.exclusiveTouch = YES;
    self.rvlvdButton.exclusiveTouch = YES;
    
    self.view.hidden = YES;
    self.containerView.backgroundColor = [UIColor rv_backgroundColor];
    self.backgroundView.backgroundColor = [UIColor rv_dimColor];
}

- (void)present
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval SlideDelay = 0.1;
    const NSTimeInterval SlideDuration = 0.5;
    
    
    self.view.hidden = NO;
    self.backgroundView.alpha = 0.0f;
    self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);
    
    [UIView animateWithDuration:BackgroundDuration animations:^{
        self.backgroundView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:SlideDuration delay:SlideDelay usingSpringWithDamping:0.85 initialSpringVelocity:0.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

- (void)dismiss
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval BackgroundDelay = 0.3;
    const NSTimeInterval SlideDuration = 0.5;
    
    [UIView animateWithDuration:BackgroundDuration delay:BackgroundDelay options:0 animations:^{
        self.backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
    
    
    [UIView animateWithDuration:SlideDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:-5.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);
    } completion:NULL];
}


- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

#pragma mark - Button Actions

- (IBAction)stlButtonTapped:(UIButton *)sender
{
    NSString *filePath = [[self documentsDirectory] stringByAppendingPathComponent:@"RevolvedModel.stl"];

    RVSTLExporter *exporter = [[RVSTLExporter alloc] init];
    [exporter exportModel:self.model toFileAtPath:filePath];

    self.filePath = filePath;
    
    [self showDocumentInteractionControllerFromRect:sender.frame];
    
}


- (IBAction)objButtonTapped:(UIButton *)sender
{
    NSString *objFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"RevolvedModel.obj"];
    
    RVOBJExporter *exporter = [[RVOBJExporter alloc] init];
    [exporter exportModel:self.model toFileAtPath:objFilePath];

    NSString *mtlFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"RevolvedMaterials.mtl"];

    [[RVColorProvider mtlString] writeToFile:mtlFilePath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *zipFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"RevolvedModel.zip"];
    
    [SSZipArchive createZipFileAtPath:zipFilePath withFilesAtPaths:@[objFilePath, mtlFilePath]];
    
    self.filePath = zipFilePath;
    
    [[NSFileManager defaultManager] removeItemAtPath:objFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:mtlFilePath error:NULL];
    
    [self showDocumentInteractionControllerFromRect:sender.frame];
}

- (IBAction)rvlvdButtonTapped:(UIButton *)sender
{
    NSString *rvlvdFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"RevolvedModel.rvlvd"];

    
    NSData *payload = [RVModelManager exportDataForModel:self.model];
    [payload writeToFile:rvlvdFilePath atomically:YES];
    
    self.filePath = rvlvdFilePath;
    
    [self showDocumentInteractionControllerFromRect:sender.frame];
}


- (IBAction)backgroundTouched:(UIControl *)sender
{
    [self dismiss];
}

#pragma mark - Document Interaction Controlle

- (void)showDocumentInteractionControllerFromRect:(CGRect)rect
{
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.filePath]];
    self.documentInteractionController.delegate = self;
    
    [self.documentInteractionController presentOptionsMenuFromRect:rect inView:self.containerView animated:YES];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
}

@end

//
//  ViewController.m
//  Transform
//
//  Created by Ron on 2021/9/15.
//

#import "ViewController.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *stringsPath;
@property (weak) IBOutlet NSTextField *jsonPath;
@property (weak) IBOutlet NSTextField *desPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stringsPath.editable = NO;
    self.jsonPath.editable = NO;
    self.desPath.editable = NO;
    // Do any additional setup after loading the view.
}


- (IBAction)stringsToJson:(id)sender {
    
    if (self.stringsPath.stringValue.length == 0) {
        [self showText:@"string路径为空！"];
        return;
    }
    if (self.desPath.stringValue.length == 0) {
        [self showText:@"输出文件路径为空！"];
        return;
    }
    [self transformStringsToJson:self.stringsPath.stringValue];
    
    
}

- (IBAction)jsonToStrings:(id)sender {
    
    if (self.jsonPath.stringValue.length == 0) {
        [self showText:@"json路径为空！"];
        return;
    }
    if (self.desPath.stringValue.length == 0) {
        [self showText:@"输出文件路径为空！"];
        return;
    }
    [self transformJsonToStrings:self.jsonPath.stringValue];
    
}

- (IBAction)choseFile:(NSButton *)sender {
    
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    if (sender.tag != 2) {
        [oPanel setCanChooseDirectories:NO];
        [oPanel setCanChooseFiles:YES];
    }else{
        [oPanel setCanChooseDirectories:YES];
        [oPanel setCanChooseFiles:NO];
    }

    if ([oPanel runModal] == NSModalResponseOK) {
        NSString *path = [[[[[oPanel URLs] objectAtIndex:0] absoluteString] componentsSeparatedByString:@":"] lastObject];
        path = [[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByExpandingTildeInPath];
        if (sender.tag == 0) {
            self.stringsPath.stringValue = path;
        } else if (sender.tag == 1) {
            self.jsonPath.stringValue = path;
        }else{
            self.desPath.stringValue = path;
        }
    }
    
}


//strings文件->json 保存在本地
-(void)transformStringsToJson:(NSString *)name{
    NSError *parseError = nil;
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:name] error:&parseError];
    if (parseError) {
        NSLog(@"string文件读取异常：%@",parseError.description);
        return;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString * oldname = [name componentsSeparatedByString:@"/"].lastObject;
    NSString * prex = [oldname componentsSeparatedByString:@"."].firstObject;
    NSString * fileName = [NSString stringWithFormat:@"%@.json",prex];
    NSString * urlName = [self creatFIleWithFileName:fileName];
    
    NSError * error;
    BOOL isWrite = [jsonStr writeToFile:urlName atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%d,%@",isWrite,error.description);
}

//json文件->Strings 保存在本地
-(void)transformJsonToStrings:(NSString *)name{
    NSError *parseError = nil;
    NSData * data = [NSData dataWithContentsOfFile:name];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    if (parseError) {
        NSLog(@"json文件读取异常：%@",parseError.description);
        return;
    }
    NSString * formatStr = [dict descriptionInStringsFileFormat];
    
    NSString * oldname = [name componentsSeparatedByString:@"/"].lastObject;
    NSString * prex = [oldname componentsSeparatedByString:@"."].firstObject;
    NSString * fileName = [NSString stringWithFormat:@"%@.strings",prex];
    NSString * urlName = [self creatFIleWithFileName:fileName];
    
    NSError * error;
    BOOL isWrite = [formatStr writeToFile:urlName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%d,%@",isWrite,error.description);
}

-(NSString *)creatFIleWithFileName:(NSString  *)fileName{
    NSString *outPutPath = self.desPath.stringValue;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:outPutPath]) {
        [fileManager createDirectoryAtPath:outPutPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    else
    {
        [fileManager removeItemAtPath:[outPutPath stringByAppendingPathComponent:fileName] error:nil];
    }
    NSString *urlName = [outPutPath stringByAppendingPathComponent:fileName];
    return urlName;
    
}

-(void)showText:(NSString *)text{
    
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = text;
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

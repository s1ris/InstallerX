#import "VeloxFolderViewProtocol.h"
#import "QuartzCore/QuartzCore.h"
#import "UIKit/UIKit.h"

@interface InstallerXFolderView : UIView <VeloxFolderViewProtocol, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate > {
         NSMutableArray *files;
         UIActionSheet *sheet;
         NSString *theOne;
         UITableView *myTable;
         UIView *view;
}

-(void)beginInstall;
@end

@implementation InstallerXFolderView

-(UIView *)initWithFrame:(CGRect)aFrame{
        self = [super initWithFrame:aFrame];
    if (self){
        myTable =[[UITableView alloc] initWithFrame: CGRectMake (0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
        [myTable setDataSource:self];
        [myTable setDelegate:self];
        [myTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:myTable];
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Documents" error:nil];
        files = [[NSMutableArray arrayWithArray:[dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", @".ipa", nil]]] retain];
        view = [[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 60, self.frame.size.height/2 - 60, 120, 120)] autorelease];
        view.hidden = YES;
        view.backgroundColor = [UIColor blackColor];
        view.layer.cornerRadius = 5;
        [view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        UIActivityIndicatorView *activityIndicatior = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(37, 37, 45, 45)];
        [activityIndicatior setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [view addSubview:activityIndicatior];      
        [activityIndicatior startAnimating];
        [self addSubview:view];
        }
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
        return 1;
}

-(NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
        switch (section) 
        {
                case 0:
                return[files count];
                break;
                default:
                break;
        }
        return -1;
}

-(UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: [NSString stringWithFormat:@"Cell %i", indexPath.section]];
        if (cell == nil)
        {
                cell =[[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: [NSString stringWithFormat:@"Cell %i", indexPath.section]] autorelease];
        }
        switch (indexPath.section)
                {
                case 0:
                        {
                        cell.textLabel.text =[files objectAtIndex:indexPath.row];
                        }
                break;
                default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
}

-(void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
        theOne =[files objectAtIndex:indexPath.row];
        sheet =[[UIActionSheet alloc] initWithTitle: [files objectAtIndex: indexPath.row] delegate: self cancelButtonTitle: nil destructiveButtonTitle: @"Cancel" otherButtonTitles:@"Install", nil];
        [sheet showInView:self];
        [sheet release];
        [tableView deselectRowAtIndexPath: indexPath animated:YES];
}

-(void) actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
        if (buttonIndex ==[actionSheet cancelButtonIndex])
                {
                }
        else if (buttonIndex == 0)
                {
                }
        else if (buttonIndex == 1)
                {
                view.hidden = NO;
                [self beginInstall];
                }
}

-(void)beginInstall {
        
        NSOperationQueue *q = [[NSOperationQueue alloc] init];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(installIPA) object:nil];
        NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(dismissView) object:nil];
        [operation1 addDependency:operation];
        [q addOperation:operation1];
        [operation release];
        [q addOperation:operation];
        [operation1 release];
}

-(void) installIPA {
        NSString *baseDirectory = @" \"/var/mobile/Documents/";
        NSString *quoteString = @"\"";
        NSString *ipaPath =[NSString stringWithFormat:@"%@%@%@", baseDirectory, theOne, quoteString];
        NSString *installScript = @"ipainstaller -f";
        NSString *finalInstall =[NSString stringWithFormat:@"%@%@", installScript, ipaPath];
        system ([finalInstall UTF8String]);
}

-(void) dismissView {
                NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Documents" error:nil];
                files = [[NSMutableArray arrayWithArray:[dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", @".ipa", nil]]] retain];
                [myTable reloadData];
                view.hidden = YES;
}

+(int)folderHeight{
        return 320;
}
@end

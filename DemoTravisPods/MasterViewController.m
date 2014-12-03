//
//  MasterViewController.m
//  DemoTravisPods
//
//  Created by Ashish ojha on 12/3/14.
//  Copyright (c) 2014 com.v2solutions. All rights reserved.
//

#import "MasterViewController.h"
#import <RestKit/RestKit.h>
#import "RKXMLReaderSerialization.h"
#import "Location.h"

@interface MasterViewController ()

@property NSArray *locations;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureRestKit];
    [self loadLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureRestKit
{
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://admin.staging.orders24-7.com/"];
    NSString *LICENSECODE = @"122122"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    NSString *PASSCODE = @"122122";
    NSString *REQUESTERID = @"22";
    NSString *SUBSCRIBERID = @"144";
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"LICENSECODE" value:LICENSECODE];
    [client setDefaultHeader:@"PASSCODE" value:PASSCODE];
    [client setDefaultHeader:@"REQUESTERID" value:REQUESTERID];
    [client setDefaultHeader:@"SUBSCRIBERID" value:SUBSCRIBERID];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeXML];
    
    objectManager.HTTPClient.allowsInvalidSSLCertificate = YES;
    
//    objectManager.managedObjectStore = [self managedObjectStore];
//    NSError *error = nil;
//    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Model.sqlite"];
//    [objectManager.managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
//    [objectManager.managedObjectStore createManagedObjectContexts];
//    
    
    
    
    
        RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Location class]];
        [venueMapping addAttributeMappingsFromDictionary:@{
                                                           @"location_desc.text":@"locationDesc"
                                                           }];
    
//    RKEntityMapping *venueMapping = [RKEntityMapping mappingForEntityForName:@"Location" inManagedObjectStore:objectManager.managedObjectStore];
//    venueMapping.identificationAttributes = @[ @"locationDesc" ];
//    [venueMapping addAttributeMappingsFromDictionary:@{@"location_desc.text":@"locationDesc"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"locations.location"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Location *object = self.locations[indexPath.row];
    cell.textLabel.text = object.locationDesc;
    return cell;
}

- (void)loadLocations
{
    
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/service/locations.xml"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSLog(@"mappingResult %@", mappingResult.description);
                                                  _locations = mappingResult.array;
                                                  [self.tableView reloadData];
                                                  
                                                  
                                                  
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}

@end

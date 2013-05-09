# Asset Distribution Manager

_A lightweight solution to manage OTA asset distribution to live iOS apps._

### The problem

iOS apps must have an app size below 50MB to be downloaded OTA from a cellular network. This results in losing a lot of potential users by not being able to download the app if they're not connected to a WiFi network.

### The solution

Do what it takes to ship the app with under 50MB of content (remove art, sound, etc.) and let ADM download those for you.

## Goals

This project was built with specific goals in mind:

* Very lightweight!
* Zero dependencies!
* NO singletons! Create as many ADMRepos as you like!
* Delegate driven! NO blocks to minimize retain cylce risk!
* Thorough documentation with Appledoc for Xcode integration!
* Unit Tested!

## Example

```objc
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/my-bucket/"];
    
    self.repo = [[ADMRepo alloc] initWithSourceURL:url repoId:@"com.adm.level1"];
    self.repo.delegate = self;
    [self.repo update];
}

- (void)repo:(ADMRepo *)repo downloadProgress:(float)progress
{
    NSLog(@"%.2f%% downloaded", progress * 100);
}

- (void)didFinishUpdatingRepo:(ADMRepo *)repo
{
    NSBundle *dogsBundle = [ADMBundle bundleWithDescriptor:@"com.adm.level1.dogs"];
    NSBundle *catsBundle = [ADMBundle bundleWithDescriptor:@"com.adm.level1.cats"];
    
    NSString *dog = [dogsBundle pathForResource:@"dog1" ofType:@"png"];
    NSString *cat = [catsBundle pathForResource:@"cat1" ofType:@"png"];
    
    self.dogImageView.image = [UIImage imageWithContentsOfFile:dog];
    self.catImageView.image = [UIImage imageWithContentsOfFile:cat];
}
```

## Server format

### Repo

ADM treats server assets as repositories. A repository is a directory with a unique name that houses any number of bundles and an `index.json` file which lists the contents of the repo.

### Bundle

A bundle is simply a tarball of a directory of assets that's named with a version identifier. For example, `cats-1.tar.gz` is a bundle that will become `cats-2.tar.gz` when new assets are added to that bundle.

### index.json

The `index.json` file lists the contents of the bundles and their versions. It looks like this:

```json
{
    "bundles": {
        "art": {
            "version": 4
        },
        "sound": {
            "version": 7
        }
    }
}
```

The bundles' dictionary keys correspond to each existing bundle name, and their version is listed as a dictionary of the bundle. This format is not subject to change. It looks more complex than necessary simply for future proofing. Currently there are no plans to create a tool to automatically build and eploy ADM repositories.

## Acknowledgements

* This project is heavily inspired by [Zinc](https://github.com/mindsnacks/Zinc-objc). If you need a more feature-complete solution, please check that out!
* ADM's concurrent download operation is heavily influenced from [AFNetworking](https://github.com/afnetworking/afnetworking)'s AFURLConnectionOperation.
* In order to avoid dependencies, I borrowed and modified a large portion of [Light-Untar-for-iOS](https://github.com/mhausherr/Light-Untar-for-iOS).

## TODO

* This project is currently in active development and should not be used in production
* Test every possible scenario
* Write more tests
* Write more documentation
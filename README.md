# Bikeshare Kit

A simple iOS framework for automatically fetching bikeshare data.

## Installation

This project uses Alamofire, installed as a submodule. Once the repository is cloned, install it using:

```
$ git submodule init
$ git submodule update
```

You should see something like this:

```
Cloning into 'Alamofire'...
remote: Counting objects: 3339, done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 3339 (delta 1), reused 0 (delta 0), pack-reused 3328
Receiving objects: 100% (3339/3339), 1.34 MiB | 1024.00 KiB/s, done.
Resolving deltas: 100% (2080/2080), done.
Checking connectivity... done.
Submodule path 'Alamofire': checked out '140bce9e7244ff1382e89323cb3370ea5072a8f0'
``` 

## Testing

Run unit tests in Xcode using cmd-U.

## Usage

### Config

You must send a valid token. Need a token? Contact [@thelowlypeon](https://github.com/thelowlypeon).

```
BSManager.configure(["token": "my_valid_auth_token"])
//then:
BSManager.sharedManager().syncServices() //...
```

Or:

```
let manager = BSManager(token: "my_valid_auth_token")
```

### Get a list of all available Bikeshare Services

```
BSManager.sharedManager().syncServices({(error) -> Void in
    if error == nil {
        print("hooray! retrieved \(manager.services.count) services")
    } else {
        print("Uh oh, there was an error: \(error)")
    }
})
```

### Set your favorite service

Set a favorite service to avoid syncing or dealing with all services.

```
BSManager.sharedManager().favoriteService = myFavoriteService
BSManager.sharedManager().persist()
```

### Persist data locally to use until updates are available

```
//on your app delegate's applicationWillResignActive()
BSManager.sharedManager().persist()

//on didFinishLaunchingWithOptions()
BSManager.sharedManager().restore()

let countOfServicesOnLaunch = BSManager.sharedManager().services.count
BSManager.sharedManager().syncServices({(error) -> Void in
    let newCount = manager.services.count
    print("retrieved \(newCount - countOfServicesOnLaunch) new services")
})
```

## KVO

You can observe changes in values using iOS's built in Key Value Observing, or KVO, or with third party libraries like ReactiveCocoa.

```
//in view controller
override func viewDidAppear(animated: Bool) {
    BSManager.sharedManager().addObserver(self, forKeyPath: "favoriteService.name", options: .New, context: nil)
    super.viewDidAppear(animated)
}

override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "favoriteService.name" {
        print("observed change to favorite service or favorite service's name: \(change)")
    }
}
```

## Notes

`BSManager`'s services are stored as a `Set` (or, in Objective-C, an `NSSet`). This means that the services
contained in the set are unique based on an internal (private) ID. This makes synchronizing
services with the API extremely fast, but also means that updates to individual services
will trigger a change event when syncing. Keep this in mind when implementing KVO.

The same is true for a `BSService`'s stations.

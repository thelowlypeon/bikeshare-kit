# Bikeshare Kit

A simple iOS framework for automatically fetching bikeshare data.

## Installation

Installation is easy, thanks to BikeshareKit having zero dependencies!

## Testing

Run unit tests in Xcode using cmd-U.

## Usage

### Config

#### Token

You must send a valid token. Need a token? Contact [@thelowlypeon](https://github.com/thelowlypeon).

```
BSManager.configure([.Token: "my_valid_auth_token"])
//then:
BSManager.sharedManager().syncServices() //...
```

Or:

```
let manager = BSManager(token: "my_valid_auth_token")
```

#### Active Stations

By default, BikeshareKit will only return active stations. To include all, pass the following param:

```
BSManager.configure([.IncludeInactiveStations: true])
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

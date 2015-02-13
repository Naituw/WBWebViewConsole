NSDictionary-Accessors
======================

Type safe accessors for NSDictionary, better used with dictionary parsed from JSON.

Before:

    id value = nil;
    value = [dictionary objectForKey:@"id"];
    if ([value isKindOfClass:[NSNumber class]]) {
        model.identifier = [value unsignedLongLongValue];
    }
    value = [dictionary objectForKey:@"title"];
    if ([value isKindOfClass:[NSString class]]) {
        model.title = value;
    }
    value = [dictionary objectForKey:@"content"];
    if ([value isKindOfClass:[NSString class]]) {
        model.content = value;
    }

Problems:

- Boilerplate code
- 64bit ids will be returned as string instead of number in some api
- Libs like [RestKit](https://github.com/RestKit/RestKit/) even lighter [JSONModel](https://github.com/icanzilb/JSONModel) are still heavy for simple apps sometimes

What you need is just [AFNetworking](https://github.com/AFNetworking/AFNetworking) + NSDictionary+Accessors

After:

    model.identifier = [dictionary unsignedLongLongForKey:@"id"];
    model.title = [dictionary stringForKey:@"title"];
    model.content = [dictionary stringForKey:@"content"];
# Vector Conventions (thanks to @Markl)

Some conventions regarding FlxVectors that I learnt thanks to @Markl's help in the Flixel discord.

## get()

`get()` either creates a new vector via `new()` , or it reuses an "old" one from the global pool.
`get()` expects coordinates as arguments so you can overwrite the past values of old vectors.
You should never use `new()` in place of `get()` .

Once the instance using the vector is destroyed you should `put()` the vector back into the global pool for recycling.

## weak()

It seems like `weak()` is just an automatic `put()` when calling functions.
It's specifically for chaining stuff together.

``` haxe
// I want to subtract the point 10, 10 from vector
var vector = FlxVector.get(1,1);

// without weak():
var tenten = FlxVector.get(10,10);
v.subtractPoint(tenten);
tenten.put();

// with weak
var tenten = FlxVector.weak(10,10);
v.subtractPoint(tenten);
// no need for this put(), subtractPoint() did it for us, because tenten was weak!
tenten.put();
```

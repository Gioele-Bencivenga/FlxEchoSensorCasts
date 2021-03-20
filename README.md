# FlxEchoSensorCasts

A project where I try to simulate some entities in an environment that use echo linecasts as periodic environment sensors.

Built using [Haxe](https://haxe.org/) + [HaxeFlixel](https://haxeflixel.com/) + [Echo Physics](https://austineast.dev/echo/) + [HaxeUI](http://www.haxeui.org/).

## Screenshot

![image](assets/git/previewPic.png)

## Pointers

[Here](https://github.com/Gioele-Bencivenga/FlxEchoSensorCasts/blob/main/source/entities/AutoEntity.hx#L203) you should find the actual line casting the ray.

I don't exactly understand [the code I wrote](https://github.com/Gioele-Bencivenga/FlxEchoSensorCasts/blob/main/source/entities/AutoEntity.hx#L197) to set the starting cast position out of the body, I'd love to know if you find a better way!


[Here](https://github.com/Gioele-Bencivenga/FlxEchoSensorCasts/blob/main/source/entities/AutoEntity.hx#L219) you should find an easy way to draw the linecast using [this `DebugLine` class](https://github.com/Gioele-Bencivenga/FlxEchoSensorCasts/blob/main/source/utilities/DebugLine.hx).

## Live Build - Broken :(

Check out the [latest html5 build of the project](https://Gioele-Bencivenga.github.io/FlxEchoSensorCasts) if you want, but know that it may be broken and/or stuck to an older version of the project.

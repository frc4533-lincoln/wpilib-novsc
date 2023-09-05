
![cheerios-wpilib](https://github.com/frc4533-lincoln/wpilib-novsc/assets/132951735/aad7e542-a570-4386-a896-088189fd797d)

wpilib-novsc is a slimmed down WPILib distribution compatible with non-standard editors and build systems.

To put it simply:
 1. I'm unpacking the ZIPs inside the tarball inside their tarball
 2. I'm moving that stuff around
 3. I'm packing some of the stuff I moved around into my own tarballs

This all runs on Github actions.

## Supported Versions

Past versions aren't and won't be supported.

Future versions will be supported as long as I don't abandon this.

## Features

 - It works somewhat
 - Works with text editors that aren't VS Code
 - Works with build systems that aren't Gradle

## Download

You need #1 and #2. You probably want #3. You may want #4.

 1. [WPILib and NI libraries](https://github.com/frc4533-lincoln/wpilib-novsc/releases/latest/download/wpilib-novsc-athena.tar.xz)
 2. [roboRIO toolchain](https://github.com/frc4533-lincoln/wpilib-novsc/releases/latest/download/wpilib-novsc-toolchain.tar.xz)
 3. [roboRIO sysroot](https://github.com/frc4533-lincoln/wpilib-novsc/releases/latest/download/wpilib-novsc-sysroot.tar.xz)
 4. [WPILib C++ and FRC documentation](https://github.com/frc4533-lincoln/wpilib-novsc/releases/latest/download/wpilib-novsc-docs.tar.xz)

## Examples

There's no official example(s) or template(s) at this time, but here's some projects using it:
 - [Our own](https://github.com/4533-phoenix/chalkydri)

If you're using it, open a Github issue and I'd be happy to add it to this list.

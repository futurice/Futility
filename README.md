Futility
========

Reusable code for iOS projects.


Contributing
------------

For all code added to this repository, the following must hold:

- Either you, or Futurice, owns the copyright
- The code is released under the three-clause BSD license (see the `LICENSE` file).

If the time you use to write some code is billed to a customer, the customer normally owns the copyright. Do not add such code here.

Publishing
----------

Futility is best distributed via [CocoaPods](http://cocoapods.org). It is currently hosted on a Futurice-internal podspec repository, found at [https://github.com/futurice/Podspecs](https://github.com/futurice/Podspecs).

After improving the code, you can publish your changes like this:

    $ cd ~/path/to/futility
    $ edit Futility.podspec
    # update version number: x.y.z
    $ pod lib lint

    $ git commit -am "Update podspec for version x.y.z"
    $ git tag 'x.y.z'
    $ git push && git push --tags
    $ pod push Futurice Futility.podspec

In the last command, substitute `Futurice` with your local name for the podspec repository. It will automatically be linted again, this time against the remote version you just published.

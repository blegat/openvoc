Openvoc
=======
[![Build Status](https://secure.travis-ci.org/blegat/openvoc.png)](http://travis-ci.org/blegat/openvoc)

Description
-----------
Openvoc is a web application that helps you create your vocabulary lists, share them and export them in various format easily.

Contribute
----------
You can find the code and the bug tracker at our
[github repository](https://github.com/blegat/openvoc).
You can contact us through our
[mailing list](https://groups.google.com/d/forum/openvoc).

To modify the code, for us as explained in the
[github help](https://help.github.com/articles/fork-a-repo).

Then, to install the gems, run

    $ bundle install --without production

Create and populate the database with

    $ bundle exec rake db:create
    $ bundle exec rake db:migrate
    $ bundle exec rake db:populate

You can now try it by running a server on a terminal with

    $ rails server # or rails s
Then open a browser at the address `http://localhost:3000/`
and should see openvoc in action running locally.

You can visualize controllers and models in picture thanks to [railroady](http://railroady.prestonlee.com/)
by installing graphviz (e.g. `sudo apt-get install graphviz`) and running

    $ bundle exec rake diagram:all
The pictures will be in the `doc` subdirectory.

You can update the annotation of the models with (already done normally)

    $ annotate -p after -mi

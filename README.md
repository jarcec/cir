CIR - Configuration files in Repository
=======================================

[![Build Status](https://travis-ci.org/jarcec/cir.svg?branch=master)](https://travis-ci.org/jarcec/cir)

This project aims at solving problem that I had for a long time - version personal configuration files in git repository in a simple way - e.g. without a need to have git repository in the root of a home directory and without the need to copy the configs around every time they change.

``cir`` solves that by maintaining a git repository in ``CIR_HOME`` (which defaults to ``~/.cir`` directory) and providing tooling for the operations.

Install
-------

Simply install ``cir`` using ``gem`` command

    gem install cir

Alternatively if you want to install a custom version from this repository run:

    gem build cir.gemspec && gem install cir-*.gem

Usage
-----

Once you'll install ``cir`` per previous instructions you can invoke it with ``cir`` command. Run ``cir -h`` to get help blurb.

The usual workflow is as follows:

Before first use, you need to initialize internal structures - the internal git repository and ``cir``'s metadata structures:

    cir init

Then you need to register files that you want to track. The files can be anywhere on the file system - ``cir`` doesn't impose any limitations to the location of files that it stores:

    cir register ~/.vimrc ~/.zshrc

If you need to see what of your registered files has changed just run ``status`` command. I personally have this command in my ``~/.zshrc`` file so that I'm notified on every shell start that certain files have changed and I should take an action):

    cir status [--all]

To express that new change in configuration file should be considered as a new state (~to commit the change) run:

    cir update ~/.vimrc

To get rid of local changes as the experiment did not worked out:

    cir restore ~/.vimrc

And finally, if you're not interested to track the configuration file any more just deregister it:

    cir deregister ~/.vimrc

Notes
-----

``cir`` primary use case is to keep track of configuration files. Whereas it is technically possibly to track any arbitrary files, it's not recommended due to assumptions in ``cir``. Using cir for large or binary files might not work properly.

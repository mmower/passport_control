Passport Control
================

Passport Control is a Rails plugin that augments ActiveRecord model classes with **per-record** callbacks. The intended purpose is to allow mocking & stubbing  in tests on a per-record, rather than per-instance, basis.

Here is a typical example of mocking a method in a test setup: (*)

    setup do
      @user = User.make
      @content = @user.contents.make
      mock( @content ).foo { "foo!" }
    end

Setting up a mock in this way works fine in a context where you can pass your mocked `@content` instance directly into your test (e.g. a unit test). But this becomes more complicated when your test is not responsible for directly providing the object you need to mock.

For example controller methods usually take the id of a record and look up an instance using `find` and friends. Calls to `find` returns the same record but a different instance to the one your mock method is installed on.

Typical work arounds to this problem involve either `any_instance` (if it's available to you), or stubbing your model class to ensure your pre-mocked instance is returned by `find`. This can get messy, especially where associations are involved.

Maybe you've wished you could simply tell Rails "Look, just mock method #foo of record 13 wherever it comes from"? That's where Passport Control comes in.

Here's an example:

    setup do
      @user = User.make
      @content = @user.contents.make
      @content.at_passport_control { |content| mock( content ).foo { "foo!" }
      get :show, :id => @content.id
    end

Calling `at_passport_control` on the instance ensures that the block is called when the record corresponding to `@content` gets instantiated by ActiveRecord, no matter what chain of methods is involved. This example ensures that when the controller method `#show` looks up the record given it's id that the returned instance correctly mocks the method `#foo`.

Test Framework Integration
--------------------------

To ensure that passport control mocks & stubs don't leak from one test to another install the PassportControl adapater. An adapter is provided for Test::Unit based systems, add the following to your `test_helper.rb`

    require 'passport_control'
    
    class Test::Unit::TestCase
      include PassportControl::Adapters::TestUnit
    end

A similar adapter should be easy enough to write for other frameworks.

The Low Down
------------

Passport Control is specifically intended for use in writing tests **not** for use in production code.

It works by replacing the `instantiate` method of ActiveRecord::Base with an augmented version that manages the per-class/per-id callback lists. Initial results suggest that this doesn't add a significant overhead during test runs but, given how often `instantiate` is going to get called during the lifetime of a real application, you don't want it in production.

Also monkeypatching such a fundamental ActiveRecord method is surely evil and angry villagers with torches and pitchforks will be involved somehow. You have been warned!

Notes
-----

* I use [Shoulda](http://github.com/thoughtbot/shoulda/tree/master), [RR](http://github.com/btakita/rr/tree/master), and [Machinist](http://github.com/notahat/machinist/tree/master) for testing.

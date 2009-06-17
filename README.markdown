Passport Control
================

Passport Control is a Rails plugin that augments ActiveRecord model classes with **per-record** callbacks. The intended purpose is to allow mocking & stubbing instances in tests on a record, rather than instance, basis.

Here is a typical example (*)

    setup do
      @user = User.make
      @content = @user.contents.make
      mock( @content ).foo { "foo!" }
    end

Setting up a mock works fine in a context where you can pass your mocked `@content` instance directly into your test (e.g. a unit test). But this becomes more complicated when your test is not responsible for providing the object you need to mock. For example controller methods usually take the id of a record and look it up using `find` and friends. Same record, different instance and your mock won't work. 

Typically to work around this you either resort to `any_instance` (if it's available to you) or stubbing your model class itself to ensure your pre-mocked instance is returned by `find`. This can get messy in cases where you access this instance via an association.

Maybe you've wished you could simply tell Rails "Look, just mock method #foo of record 13 wherever it comes from" instead? That's where Passport Control comes in.

Here's an example:

    setup do
      @user = User.make
      @content = @user.contents.make
      @content.at_passport_control { |content| mock( content ).foo { "foo!" }
      get :show, :id => @content.id
    end

Calling `at_passport_control` on the instance ensures that the block is called when the record corresponding to `@content` gets instantiated by ActiveRecord, no matter what chain of methods is involved. In this example installing it installs mock method on instances of that record.

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

It works by replacing the `instantiate` method of ActiveRecord::Base with an augmented version that manages the per-instance callback list. Initial results suggest that this doesn't add a significant overhead during test runs but, given how often `instantiate` is going to get called during the lifetime of a real application, you don't want it in production.

* I use [Shoulda](http://github.com/thoughtbot/shoulda/tree/master), [RR](http://github.com/btakita/rr/tree/master), and [Machinist](http://github.com/notahat/machinist/tree/master) for testing.

Passport Control
================

Passport Control is a Rails plugin that augments ActiveRecord model classes with per-record callbacks.

The intended purpose is to allow mocking & stubbing instances in tests on a record, rather than instance, basis. So for example*

    setup do
      @user = User.make
      @content = @user.contents.make
      mock( @content ).foo { "foo!" }
    end

Works in a context where you pass `@content` into your test (e.g. a unit test) but does not work where the code under test retrieves the object itself using `find` and friends. I keep running into this with controller methods.

Typically you must resort to `any_instance` (if available) or stubbing your model class itself to ensure your pre-mocked instance is returned by `find`. This can get messy in cases where you access this instance via associated collections. Maybe you've wished you could tell Rails "Mock method #foo of record 13" instead? And have it do the necessary work? That's where Passport Control comes in.

Here's an example:

    setup do
      @user = User.make
      @content = @user.contents.make
      @content.at_passport_control { |content| mock( content ).foo { "foo!" }
      get :show, :id => @content.id
    end

Calling `at_passport_control` on the instance ensures that the block is called when the record corresponding to `@content` gets instantiated by ActiveRecord, no matter what chain of methods is involved. In this example installing a mock on that record.

Test Framework Integration
--------------------------

To ensure that passport control mocks & stubs don't leak from one test to another install the PassportControl adapater. An adapter is provided for Test::Unit based systems, add the following to your `test_helper.rb`

    require 'passport_control'
    
    class Test::Unit::TestCase
      include PassportControl::Adapters::TestUnit
    end

A similar adapter should be easy enough to write for other frameworks.


* I use [Shoulda](http://github.com/thoughtbot/shoulda/tree/master), [RR](http://github.com/btakita/rr/tree/master), and [Machinist](http://github.com/notahat/machinist/tree/master) for testing.

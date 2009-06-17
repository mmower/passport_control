Passport Control
================

Passport Control is a Rails plugin that augments ActiveRecord model classes with per-record callbacks.

The intended purpose is to allow mocking & stubbing instances in tests on a record, rather than instance, basis. So for example

    setup do
      @content = Content.make
      mock( @content ).foo { "foo!" }
    end

Works in a context where you pass `@content` into your test (e.g. a unit test) but does not work where the code under test
retrieves the object itself using `find` and friends.

Typically you must resort to `any_instance` (if available) or mocking your model class itself to ensure your pre-mocked instnace is returned by `find`. Neither is pleasant and, if you're like me, you might wish to be able to say "Mock method foo of record 13". That's where Passport Control comes in.

Here's an example:

    setup do
      @content = Content.make
      @content.border_check { |content| mock( content ).foo { "foo!" }
    end

This will ensure that when the record corresponding to @content is instantiated by ActiveRecord (no matter how) that the mock will be put in place.


## Theory

1. There are three types of tests in flutter: unit tests, integration tests, widget tests. We need tests to verify if the software we designed is performing according to the
expectations. 

- Unit Test: Take AuthService and test on given conditions and test   them, We need to guard ourselves against unintentional edits. We could've left the AuthProviders or AuthService according to our expectations but if a collaborator make changes with it, unit tests are guards for such types of issues. 
- Integration Test:    To make sure that the code is working end-to-end but UI isn't involved. For example, checking the login functionality. 
- Widget Test:         A way for you to test that the widgets you have created are working correctly. The UI is conforming to the rules. 

> __TDD: Test Driven Development, tests need to be written before writing the code itself.__

2.  Dev Development aren't added when the app is shipped and released, they are only in the development mode. 

3. __Path Provider__ allows us to retrieve the path from the sandboxes of mobile phones that are at the kernel-level. __Path__ provides us to utilize and work with those paths. 

4. __Factory Constructor:__ The reason of using a factory constructor is that, it is the same as a normal constructor but you can return something using a factory constructor, moreover, we can put a conditional statement on a factory constructor. 

## Practical

1. If the UI gets stuck on a white screen or not running properly. 
    - ```flutter clean```
    - ```flutter run --debug``` 

2. If you want some specific function from a library we can use the show command ```import 'package:xxx/xxx.dart show abc'```

## Commands

1. ```flutter pub add test --dev``` // to add tests to your flutter application 
2. ```flutter pub add xxx``` for adding a new package

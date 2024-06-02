                                                                                        ## Theory:

1. There are three types of tests in flutter: unit tests, integration tests, widget tests. We need tests to verify if the software we designed is performing according to the
expectations. 

 - Unit Test:           Take AuthService and test on given conditions and test them, We need to guard ourselves against unintentional edits. We could've left the AuthProviders
                        or AuthService according to our expectations but if a collaborator make changes with it, unit tests are guards for such types of issues. 
 - Integration Test:    To make sure that the code is working end-to-end but UI isn't involved. For example, checking the login functionality. 
 - Widget Test:         A way for you to test that the widgets you have created are working correctly. The UI is conforming to the rules. 

TDD: Test Driven Development, tests need to be written before writing the code itself. 

2. Dev Development aren't package when the app is shipped and released, they are only in the development mode. 

                                                                                        ##Practical: 

1. If the UI gets stuck on a white screen or not running properly. 
    - flutter clean
    - flutter run --debug 

2. flutter pub add test --dev // to add tests to your flutter application 

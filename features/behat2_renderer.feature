  Feature: Behat2 Renderer

  Background:
    Given a file named "behat.yml" with:
      """
      default:
        formatters:
            html:
                output_path: %paths.base%/build
        extensions:
            emuse\BehatHTMLFormatter\BehatHTMLFormatterExtension:
                name: html
                renderer: Behat2
                file_name: Index
                print_args: true
                print_outp: true
                loop_break: true
        suites:
            suite1:
                paths:    [ "%paths.base%/features/suite1" ]
            suite2:
                paths:    [ "%paths.base%/features/suite2" ]
            suite3:
                paths:    [ "%paths.base%/features/suite3" ]
      """
    Given a file named "features/bootstrap/FeatureContext.php" with:
      """
      <?php
        use Behat\Behat\Context\CustomSnippetAcceptingContext,
            Behat\Behat\Tester\Exception\PendingException;
        class FeatureContext implements CustomSnippetAcceptingContext
        {
            public static function getAcceptedSnippetType() { return 'regex'; }
            /** @When /^I give a passing step$/ */
            public function passingStep() {
              print_r("I am a passing step");
              PHPUnit_Framework_Assert::assertEquals(2, 2);
            }
            /** @When /^I give a failing step$/ */
            public function failingStep() {
              PHPUnit_Framework_Assert::assertEquals(1, 2, 'I am a failing step');
            }
            /** * @When /^I give a pending step$/ */
            public function somethingNotDoneYet() {
                throw new PendingException();
            }
        }
      """

 Scenario: Multiple Suites with multiple results
    Given a file named "features/suite1/suite_failing_with_passing.feature" with:
      """
      Feature: Suite failing with passing scenarios
        Scenario: Passing scenario
          Then I give a passing step
        Scenario: One Failing step
          Then I give a failing step
        Scenario: One Pending step
          Then I give a pending step
        Scenario: Passing and Pending steps
          Then I give a passing step
          Then I give a pending step
        Scenario: Passing and Failing steps
          Then I give a passing step
          Then I give a failing step
      """
    Given a file named "features/suite2/suite_passing.feature" with:
      """
      Feature: Suite passing
        Scenario: Passing scenario
          Then I give a passing step
      """
    Given a file named "features/suite3/suite_pending.feature" with:
      """
      Feature: Suite with pending scenario
        Scenario: One pending step
          Then I give a pending step
      """
    When I run "behat --no-colors"
    Then process output should be:
      """

      --- FeatureContext has missing steps. Define them with these snippets:

          /**
           * @Then /^I give a pending step$/
           */
          public function iGiveAPendingStep()
          {
              throw new PendingException();
          }


      """
    And report file for Behat2 should exists
    And report file should contain:
      """
                      <p class="features">
                          3 features ( <strong class="passed">1 success</strong> <strong class="failed">2 fail</strong> )
                      </p>
                      <p class="scenarios">
                          7 scenarios ( <strong class="passed">2 success</strong> <strong class="failed">5 fail</strong> )
                      </p>
                      <p class="steps">
                          9 steps ( <strong class="passed">4 success</strong> <strong class="pending">3 pending</strong> <strong class="failed">2 fail</strong> )
                      </p>
      """
    And report file should contain:
      """
      I am a passing step
      """
    And report file should contain:
      """
      I am a failing step
      """

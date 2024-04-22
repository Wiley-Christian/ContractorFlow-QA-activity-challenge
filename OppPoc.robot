*** Settings ***
Documentation       Salesforce opportunity creation example.
Library             QWeb

Test Teardown       Close Tab


*** Variables ***
${OPPORTUNITY_NAME}             ContractorFlow Example Opportunity
${BROWSER}                      Chrome
${SALESFORCE_URL}               Use Trailhead Playground
${USERNAME}                     Your Username
${PASSWORD}                     Your Password
${XPATH_LOGIN_BUTTON}           //input[@id='Login']
${XPATH_USERNAME_FIELD}         //input[@id='username']
${XPATH_PASSWORD_FIELD}         //input[@id='password']
${XPATH_AFTER_LOGIN}            //div[contains(@class,"forceBrandBand")]    # main underlying div
${XPATH_HOME_MENU}              //a[contains(@class,"slds-context-bar__label-action")]/span[text() = "Home"]
${XPATH_APP_LAUNCHER}           //div[@class="slds-icon-waffle"]
${XPATH_SEARCH_TOP_1}           //header[@id="oneHeader"]//button[@aria-label="Search"]
${XPATH_SEARCH_BAR}             //input[@placeholder="Search..."]
${XPATH_ALL_OPPORTUNITIES}      //mark[text() = "All Opportunities"]
${XPATH_OPPORTUNITY_NAME}       //input[@name="Name"]
${CLOSE_DATE_FIELD}             //input[@name="CloseDate"]
${CLOSE_DATE}                   12/31/2024
${XPATH_STAGE_SELECT}           //button[contains(@aria-label,"Stage - Current Selection:")]
${STAGE_1}                      Prospecting
${STAGE_2}                      Qualification
${SAVE_BUTTON}                  //button[@name="SaveEdit"]
${XPATH_CLOSE_TAB}              //button[@class="slds-button slds-button_icon slds-m-right_x-small"]
${XPATH_ACTION_ARROW}
...    //li[contains(@class, "slds-dropdown-trigger slds-dropdown-trigger_click slds-button_last")]//button
${XPATH_DELETE_BUTTON}          //a/span[text()="Delete"]
${XPATH_DELETE_CONFIRM}         //button[@title="Delete"]
${XPATH_CLOSE_ERROR}            //span[text() = "Unable to load"]/parent::a/following-sibling::button


*** Test Cases ***
Login Test
    [Documentation]    Opens the browser and logs in to Salesforce
    Login To Salesforce If Not Already

Create New Opportunity
    [Documentation]    Login To Salesforce If Not Already and create a new opportunity
    Login To Salesforce If Not Already
    Navigate Waffle Menu    Opportunities
    Create Opportunity    ${STAGE_1}

Edit Opportunity
    [Documentation]    Login To Salesforce If Not Already and modify the opportunity we just created
    Login To Salesforce If Not Already
    Search For Opportunity    ${OPPORTUNITY_NAME}
    Modify Stage    ${STAGE_2}


*** Keywords ***
Login To Salesforce If Not Already
    ${loggedInAlready}=    Run Keyword And Return Status    Verify Element    ${XPATH_AFTER_LOGIN}    1s
    IF  ${loggedInAlready}    RETURN    
    Open Browser To Salesforce
    Input Username And Password
    Submit Credentials
    Verify Login Successful

Navigate Waffle Menu
    [Documentation]    Clicks the waffle menu and selects the choice specified
    [Arguments]    ${choice}
    Click Element    ${XPATH_APP_LAUNCHER}
    Wait Until Keyword Succeeds   3x    3s    Type Text    Search apps and items...    ${choice}    timeout=3s
    Click Element    //a[@data-label \= "${choice}"]
    Wait Until Keyword Succeeds    15x    1s    Verify Text    ${choice}    5s

Create Opportunity
    [Arguments]    ${stage}
    Click Text    New
    Type Text    ${XPATH_OPPORTUNITY_NAME}    ${OPPORTUNITY_NAME}
    Type Text    ${CLOSE_DATE_FIELD}    ${CLOSE_DATE}
    Choose Stage    ${stage}
    Wait Additional Time
    Click Element    ${SAVE_BUTTON}
    Verify Stage    ${stage}

Search For Opportunity
    [Documentation]    Click the global search bar at the top and search for the opportunity name
    [Arguments]    ${opportunity_name}
    Log To Console    \nAbout to search for ${opportunity_name}
    Click Home Menu
    Click Element    ${XPATH_SEARCH_TOP_1}
    Log To Console    We clicked the Search bar. Entering ${opportunity_name} now.
    Type Text    ${XPATH_SEARCH_BAR}    ${opportunity_name}
    Log To Console    Clicking on it
    ${searchXpath}=    Set Variable    //search_dialog-instant-result-item//span[@title\="${opportunity_name}"]
    ${found}=    Run Keyword And Return Status     Verify Element    ${searchXpath}    2s
    Log To Console    Verifying ${opportunity_name} found = ${found}
    IF    ${found}
        Click Element    ${searchXpath}    .5s
        Verify Element    //h1//*[text() \= "${opportunity_name}"]    5s
        RETURN     ${True}
    END
    Log To Console    Did not find an existing opportunity to click. Returning False
    RETURN     ${False}


Modify Stage
    [Arguments]    ${stage}
    Click Text    Edit
    Choose Stage    ${stage}
    Click Element    ${SAVE_BUTTON}
    Verify Stage    ${stage}

Choose Stage
    [Documentation]    Clicks the Stage drop-down and selects the specified stage (but does not click the submit button)
    [Arguments]    ${stage}
    Click Element    ${XPATH_STAGE_SELECT}    # clicks the actual input field (it's a button though) based on the aria-label to expand it
    Click Element    //div[@aria-label\="Stage"]//span[text() \= "${stage}"]    # click the stage in the drop-down
    Verify Element    //button[@aria-label\="Stage - Current Selection: ${stage}"]    3s    # the selected stage in the input field should have changed

Verify Stage
    [Documentation]    Verifies that the specified stage is the one that is current in the Stage History
    [Arguments]    ${stage}
    Verify Element    //li/div/div[@title\="Stage:"]/../div/span[text() \= "${stage}"]    # Looks at the Stage in the Stage History

Close Error Tab If Exists
    ${errorExists}=    Run Keyword And Return Status    Verify Element    ${XPATH_CLOSE_ERROR}    1s
    IF  ${errorExists}
        Log To Console    Closing Error Tab
        Click Element     ${XPATH_CLOSE_ERROR}    1s
    END

Close Tab
    Close Error Tab If Exists
    Wait Additional Time
    Run Keyword And Ignore Error    Click Element    ${XPATH_CLOSE_TAB}    2s
    Click Home Menu

Open Browser To Salesforce
    Open Browser    ${SALESFORCE_URL}    ${BROWSER}
    Maximize Window
    Verify Title    Login | Salesforce

Input Username And Password
    Type Text    ${XPATH_USERNAME_FIELD}    ${USERNAME}
    Type Text    ${XPATH_PASSWORD_FIELD}    ${PASSWORD}

Submit Credentials
    Click Element    ${XPATH_LOGIN_BUTTON}

Verify Login Successful
    Wait Until Keyword Succeeds    15x    3s    Verify Element    ${XPATH_AFTER_LOGIN}    5s

Wait Additional Time
    Log Screenshot
    Log To Console    Waiting 5 additional seconds
    Sleep    5s

Delete Opportunity
    Click Element    ${XPATH_ACTION_ARROW}
    Click Element    ${XPATH_DELETE_BUTTON}
    Verify Text    Are you sure you want to delete this opportunity?
    Click Element    ${XPATH_DELETE_CONFIRM}

Click Home Menu
    Click Element    ${XPATH_HOME_MENU}

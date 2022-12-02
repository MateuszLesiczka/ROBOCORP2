*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.       
Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Desktop
Library    RPA.Tables
Library    RPA.JavaAccessBridge
Library    DateTime
Library    RPA.FileSystem
Library    RPA.Archive
Library    RPA.RobotLogListener
Library    RPA.Robocorp.Vault
Library    Collections
Library    RPA.Dialogs


*** Tasks *** 
Orders robots from RobotSpareBin Industries Inc.
    ${filename.url}=    InputData
    Create Env  
    Open Browser
    Download The Document
    Order Your Robot
    ${rows}=    Get Documents
    FOR    ${row}    IN    @{rows}
    Fill The Form    ${row}
    END
    Clear Env
    Create ZIP    ${filename.url}
    [Teardown]    Close Window
*** Variables ***
${Output}=    C:/temp/ROBOCROP2LEVEL
${prestatus}=    True

*** Keywords ***
InputData
    Add heading    Provide the finall file name
    Add text input    name=url    label=filename
    ${filename}=    Run dialog
    Log To Console     ${filename.url}
    RETURN    ${filename.url}
Create Env
    ${status}    Does Directory Exist    ${Output}
    IF    ${status} == True
        Remove Directory    ${Output}    recursive=${True}     
    END
    Wait Until Removed    ${Output}
    Create Directory    ${Output}
Open Browser
    ${page}=    Get Secret    page
    Open Available Browser    ${page}[url]    maximized=True
Order Your Robot
    Click Button    OK
Get Documents
    ${rows}=    Read table from CSV    ${Output}${/}orders.csv    header=True
    RETURN   ${rows}
Download The Document
    Download    https://robotsparebinindustries.com/orders.csv    ${Output}${/}orders.csv    
Clear Env
    Remove File    ${Output}${/}orders.csv 
    Remove File    sales_summary.png
    Remove File    sales_summary.pdf
Create ZIP
    [Arguments]    ${filename.url}    
    Log To Console    ${filename.url}            
    Archive Folder With Zip    C:${/}temp${/}ROBOCROP2LEVEL    C:/temp/${filename.url}.zip

Fill The Form
    [Arguments]    ${row}
    Select From List By Index    head       ${row}[Head]
    Click Button    id-body-${row}[Body]
    Input Text    address    ${row}[Address]
    Input Text    class:form-control    ${row}[Legs]  
    Click Button    preview
    Wait And Click Button    id:order
    FOR    ${counter}    IN RANGE    0    100
        ${error}=    Is Element Visible    //*[@id="root"]/div/div[1]/div/div[1]/div
        IF    ${error} == True    Click Element If Visible    id:order
        IF    ${error} == False    BREAK
    END    
    #Click Button    order
    Wait Until Element Is Visible    robot-preview-image
    ${robot_picture}=    Get Element Attribute    receipt    outerHTML
    Screenshot    robot-preview-image    sales_summary.png
    Html To Pdf    ${robot_picture}    sales_summary.pdf
    Add Watermark Image To Pdf    image_path=sales_summary.png    source_path=sales_summary.pdf    output_path=C:${/}temp${/}ROBOCROP2LEVEL/output${${row}[Order number]}.pdf
    Click Button    order-another
    Click Button    OK










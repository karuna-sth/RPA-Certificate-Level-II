*** Settings ***
Documentation    order processing bot
Library    RPA.Browser.Selenium
Library    RPA.Archive
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Tables
Library    RPA.JavaAccessBridge

*** Variables ***
${image_path}=    ${CURDIR}${/}output${/}images${/}
${reciepts_path}=    ${CURDIR}${/}output${/}reciept${/}
${zip_path}=    ${CURDIR}${/}output${/}


*** Tasks ***
order robots from robotsparebinindustries
    Download orders file
    ${orders}=    get orders
    open ordering site
    Maximize Browser Window
    FOR    ${order}    IN    @{orders}
        close modal
        Fill one information    ${order}
        preview the robot
        Wait Until Keyword Succeeds    5x    2s   order the robot
        create pdf    ${order}[Order number]
        screenshot the robot    ${order}[Order number]
        Embeed robot image to receipt pdf    ${order}[Order number]
        next order
    END
    create archive



*** Keywords ***
get orders
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Download orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

open ordering site
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

close modal
    Click Button    xpath://button[normalize-space()='OK']

Fill one information
    [Arguments]    ${order}
    Select From List By Value    name:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

preview the robot
    Click Button    xpath://button[@id='preview']

order the robot
    Click Button    xpath://button[@id='order']
    Wait Until Page Contains Element    id:order-completion

create pdf
    [Arguments]    ${filename}
    Wait Until Element Is Visible    id:receipt
    ${html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${html}    ${reciepts_path}${filename}.pdf

screenshot the robot
    [Arguments]    ${filename}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    
    ...    ${image_path}${filename}.png

next order 
    Click Button    xpath://button[@id='order-another']

Embeed robot image to receipt pdf
    [Arguments]    ${filename}
    Add Watermark Image To Pdf    
    ...    ${image_path}${filename}.png    
    ...    ${reciepts_path}${filename}.pdf
    ...    ${reciepts_path}${filename}.pdf

create archive
    Archive Folder With Zip    ${reciepts_path}    ${zip_path}receipts.zip


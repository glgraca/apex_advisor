# apex_advisor

## Oracle Apex Advisor Execution from PL/SQL

Apex Advisor is an analysis tool built into Oracle Apex to help you verify your applications.

It will check for:

- Programming errors
- Security issues
- Warnings
- Performance
- Usability
- Quality assurance
- Accessibility

It was only really designed to be invoked from the web interface. A bit of work is needed in order to call it from PL/SQL, which you will probably want to do if you want to automate the process.

This package makes the job of calling it from PL/SQL easier. 

## Compatibility

It has been tested with Apex 5 and Apex 18.2.

## Installation

It is easier to compile the package in the Apex schema (i.e. APEX_050000 or APEX_180200). The results table you can store anywhere, as long as you give the necessary grants to the schema where the package is compiled.

## How to use it

```sql
-- Check all applications asynchronously
exec pk_apex_advisor.execute_advisor_async();

-- Check all applications synchronously
exec pk_apex_advisor.execute_advisor();

-- Check one application asynchronously
exec pk_apex_advisor.execute_advisor_async(123);

-- Check one application synchronously
exec pk_apex_advisor.execute_advisor(123);
```

The procedures without parameters will not execute the advisor for applications that have not been updated since the last execution.
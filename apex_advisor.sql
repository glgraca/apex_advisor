create or replace package apex_advisor AS 

  procedure create_apex_session(
    p_app_id in apex_applications.application_id%type,
    p_app_user in apex_workspace_activity_log.apex_user%type,
    p_app_page_id in apex_application_pages.page_id%type default 1
  );

  procedure delete_apex_session;
  
  procedure execute_advisor_async(p_app_id in number, p_log_date date default sysdate);

  procedure execute_advisor(p_app_id in number, p_log_date date default sysdate);

  procedure execute_advisor;

END apex_advisor;

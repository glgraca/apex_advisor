CREATE OR REPLACE
PACKAGE BODY apex_advisor AS

  type array_t is varray(29) of varchar2(64);
  g_all_options array_t:=array_t(
    --Errors
    'SUBSTITUTION_SYNTAX', 
    'COLUMN_SYNTAX', 
    'BIND_VARIABLE_SYNTAX', 
    'APPL_PAGE_ITEM_REF', 
    --Filters
    'PAGE_NUMBER_EXISTS', 
    'VALID_SQL_PLSQL_CODE',
    'DML_PROCESSES',
    'BRANCH_SEQUENCE',
    'WHEN_BUTTON_PRESSED',
    'BUTTON_DA_COMPATIBLE',
    --Security    
    'SQL_INJECTION',
    'INSECURE_APPLICATION_DEFAULTS',
    'AUTHORIZATION',
    'SESSION_STATE_PROTECTION',
    'BROWSER_SECURITY',
    --Warnings
    'IS_ITEM_OF_PAGE',
    'IS_ITEM_OF_TARGET_PAGE',
    'PAGE_ITEM_REF_AS_STRING',
    'CLEAR_CACHE_PAGE_NUMBER',
    'ITEM_NAME_LENGTH',
    'BUTTON_DA_INCONSISTENT_REFS',
    'AJAX_ITEMS_WITH_SSP',
    --Performance
    'V_FUNCTION_IN_SQL',
    --Usability
    'TARGET_PAGE_AUTH_USABILITY',
    --Component
    'VALIDATION_ASSOCIATED_ITEM',
    --Quality Assurance
    'HARDCODED_APPLICATION_ID',
    'REPORT_DEFAULT_ORDER',
    'HAS_HELP_TEXT',
    'DEPRECATED_ATTRIBUTES'
  );


  procedure create_apex_session(
    p_app_id in apex_applications.application_id%type,
    p_app_user in apex_workspace_activity_log.apex_user%type,
    p_app_page_id in apex_application_pages.page_id%type default 1
  ) as
    l_workspace_id apex_applications.workspace_id%type;
    l_cgivar_name  owa.vc_arr;
    l_cgivar_val   owa.vc_arr;
  begin

    htp.init;

    l_cgivar_name(1) := 'REQUEST_PROTOCOL';
    l_cgivar_val(1) := 'HTTP';

    owa.init_cgi_env(
      num_params => 1,
      param_name => l_cgivar_name,
      param_val => l_cgivar_val );

    select workspace_id
    into l_workspace_id
    from apex_applications
    where application_id = p_app_id;

    wwv_flow_api.set_security_group_id(l_workspace_id);

    apex_application.g_instance := 1;
    apex_application.g_flow_id := p_app_id;
    apex_application.g_flow_step_id := p_app_page_id;

    apex_custom_auth.post_login(
      p_uname => p_app_user,
      p_session_id => null, -- could use APEX_CUSTOM_AUTH.GET_NEXT_SESSION_ID
      p_app_page => apex_application.g_flow_id||':'||p_app_page_id);
  end create_apex_session;
  
  procedure log_results(p_app_id number, p_date date) is
  begin
    insert into advisor_apex_results (app_id, dt_verification, seq_id, position, object_type, url, rule_group, rule_name, description) 
    
    select p_app_id,p_date, seq_id, dbms_lob.substr(c001, 4000, 1), dbms_lob.substr(c003, 4000, 1), dbms_lob.substr(c004, 4000, 1),
           dbms_lob.substr(c005, 4000, 1), dbms_lob.substr(c006, 4000, 1), dbms_lob.substr(c007, 4000, 1)
    from wwv_flow_collections$ c
         inner join wwv_flow_collection_members$ m on c.id=m.collection_id
         where c.user_id='ADMIN' and c.collection_name='FLOW_ADVISOR_RESULT';
  end;
  
  procedure execute_advisor(p_app_id number, p_log_date date default sysdate)
  is
    options wwv_flow_global.vc_arr2;
  begin
    for i in 1..g_all_options.count loop
      options(i):=g_all_options(i);
    end loop;
    
    create_apex_session(p_app_id, 'ADMIN', 1);
    
     wwv_flow_advisor_dev.check_application(p_application_id=>p_app_id, p_check_list=>options);
     
     log_results(p_app_id, p_log_date);
  end;
  
  procedure execute_advisor
  is 
    l_log_date date:=sysdate;
  begin
    for app in (select * from apex_applications where workspace!='INTERNAL') loop
      execute_advisor(app.application_id, l_log_date);
    end loop;
  end;
  

end apex_advisor;

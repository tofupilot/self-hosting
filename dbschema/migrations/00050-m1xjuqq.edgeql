CREATE MIGRATION m1xjuqqrzayfzogw7dgbrxq74biky34aldlqx7fry3q6zvvhor34ga
    ONTO m1zrdahoakukehxbpu7trllkeixxafpsus7mhaevusxr7jpiiqoy6q
{
  ALTER TYPE default::Action {
      DROP ACCESS POLICY super_admin;
  };
  ALTER TYPE default::ActionTemplate {
      DROP ACCESS POLICY super_admin;
  };
  ALTER TYPE default::Issue {
      DROP ACCESS POLICY super_admin;
  };
  ALTER TYPE default::Product {
      DROP ACCESS POLICY super_admin;
  };
  ALTER TYPE default::Requirement {
      DROP ACCESS POLICY super_admin;
  };
};

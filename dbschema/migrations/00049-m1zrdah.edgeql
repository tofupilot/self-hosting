CREATE MIGRATION m1zrdahoakukehxbpu7trllkeixxafpsus7mhaevusxr7jpiiqoy6q
    ONTO m1ogyedihbs7ehhwgarluovax5lq76a6ot3awe4lqk5v3b7cndflva
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY org_members_have_full_access USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
};

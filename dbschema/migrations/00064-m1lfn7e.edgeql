CREATE MIGRATION m1lfn7edwu5yxqctihj3tkdh75b2gi6lqvntn5c4roa5mwg7bmpctq
    ONTO m1rszu4dkd22atmptlq4jndqqolp2x6x4o5a4tugn365rxghufetuq
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY org_members_have_full_access RENAME TO IAllowOrgMemberToDoEveryting;
  };
};

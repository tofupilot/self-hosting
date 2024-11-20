CREATE MIGRATION m1x6ogjdokijjuxykt5wcszaoly5wfrwvjcs5bfwl5vkaagwj5yhga
    ONTO m1capj2zg2huhflizo62mtvli5eclmikvdvojfuf75qmmja5z2hnwq
{
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeIsMemberOff ALLOW SELECT;
      DROP PROPERTY componentLength;
      DROP PROPERTY revisionLength;
      DROP PROPERTY unitLength;
  };
};

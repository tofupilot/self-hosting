CREATE MIGRATION m1fhnhnhjakgevu7z4axnxxdwuzzvriv7wz4uzjrl5n64bza4mimuq
    ONTO m1zm2w3bsr3zdv2hjlbuki4jrtg7hvbhmyv3cmaka5olujnbfj7u7q
{
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowSuperAdminToSelect
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};

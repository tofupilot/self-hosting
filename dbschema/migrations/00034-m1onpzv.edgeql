CREATE MIGRATION m1onpzv6hqtzf4xqlk66s4cfcacr5ikicukjh3p7tctvjfckt7joha
    ONTO m1pjg4xmyjbc3hxh4u77dc7f5m55gncozyu5yjwi3j6v4v3iojypwa
{
  ALTER TYPE default::User {
      CREATE MULTI LINK activity := (.<actor[IS default::Activity]);
  };
};

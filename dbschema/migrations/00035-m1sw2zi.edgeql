CREATE MIGRATION m1sw2ziynjna5a4hqtibjbq5ywliue6tw5bxz46pnbck3xjjsypexa
    ONTO m1onpzv6hqtzf4xqlk66s4cfcacr5ikicukjh3p7tctvjfckt7joha
{
  ALTER TYPE activity::Activity {
      CREATE ACCESS POLICY access_own_activity
          ALLOW SELECT USING ((GLOBAL default::currentUserId ?= .actor.id));
  };
};

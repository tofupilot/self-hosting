CREATE MIGRATION m1f5nt6vd2ghayqkimaanvqezwpv5vdpzniw6cori67tzu4tfn5vlq
    ONTO m1sw2ziynjna5a4hqtibjbq5ywliue6tw5bxz46pnbck3xjjsypexa
{
  ALTER TYPE default::User {
      ALTER LINK activity {
          USING (.<actor[IS activity::Activity]);
      };
  };
};

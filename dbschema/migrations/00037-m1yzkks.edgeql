CREATE MIGRATION m1yzkks6a53zfcfeikhjunw33ezeuquih2yd5z75t3ejci3a46mjdq
    ONTO m1f5nt6vd2ghayqkimaanvqezwpv5vdpzniw6cori67tzu4tfn5vlq
{
  ALTER TYPE default::User {
      ALTER LINK activity {
          RENAME TO activities;
      };
  };
};

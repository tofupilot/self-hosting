CREATE MIGRATION m17t5khlahx3wt7yommxotibwwoqftiparc33ubeoy7nvbi6av6hya
    ONTO m1yzkks6a53zfcfeikhjunw33ezeuquih2yd5z75t3ejci3a46mjdq
{
  ALTER TYPE default::Activity {
      DROP LINK actor;
      DROP PROPERTY action;
      DROP PROPERTY timestamp;
  };
  DROP TYPE default::LabelChangeActivity;
  DROP TYPE default::StatusChangeActivity;
  DROP TYPE default::UserSessionActivity;
  DROP TYPE default::Activity;
};

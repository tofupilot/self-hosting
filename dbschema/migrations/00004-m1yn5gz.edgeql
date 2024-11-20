CREATE MIGRATION m1yn5gz3fdojqwwr33kylcdpxzuxsu76ds6yhz5optsmh74etjotta
    ONTO m1ogxcxhtccjfqqsb3draorefr7a4llk66wcyafpsrewjioxyspi4a
{
  ALTER TYPE default::User {
      ALTER ACCESS POLICY server_can_list_and_insert ALLOW SELECT, UPDATE, INSERT;
  };
};

CREATE MIGRATION m1zbmd27fyejl5worr465bmycianhf2woui7q3mitaebp3ojov7atq
    ONTO m17t5khlahx3wt7yommxotibwwoqftiparc33ubeoy7nvbi6av6hya
{
  ALTER TYPE activity::Activity {
      ALTER ACCESS POLICY access_own_activity ALLOW SELECT, INSERT;
  };
};

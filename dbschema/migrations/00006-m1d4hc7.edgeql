CREATE MIGRATION m1d4hc7zngpnsere6t2xz3ml6l7rmjjqxxchuhlfqdachv3ywkblva
    ONTO m1imorjjaxektph7aqbltq6vwyylyf3lztpgczkqz2hta5twa26sqa
{
  ALTER TYPE default::User {
      ALTER ACCESS POLICY update_own_data ALLOW ALL;
  };
};

CREATE MIGRATION m1ob5enzfo6jyo6sqbwwxv6c4mwlyzgefdqspckjbddh47niifyxja
    ONTO m1mvg4kftnut3tnerz3ertkkvahxzoa7fr7mchsbhaks3a3ldoyusa
{
  ALTER TYPE activity::LabelChange {
      ALTER LINK new {
          SET MULTI;
      };
  };
  ALTER TYPE activity::LabelChange {
      ALTER LINK old {
          SET MULTI;
      };
  };
};

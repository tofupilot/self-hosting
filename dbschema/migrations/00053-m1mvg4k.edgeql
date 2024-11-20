CREATE MIGRATION m1mvg4kftnut3tnerz3ertkkvahxzoa7fr7mchsbhaks3a3ldoyusa
    ONTO m1ttmjfikgulue7kc3hhsena234ssx7wtlslh547jkjoedjj2cxn5q
{
  CREATE TYPE activity::LabelChange EXTENDING activity::Activity {
      CREATE LINK new -> default::Label {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE LINK old -> default::Label {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE REQUIRED LINK primitive -> default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
  };
  CREATE TYPE activity::OwnerChange EXTENDING activity::Activity {
      CREATE LINK new -> default::User {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE LINK old -> default::User {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE REQUIRED LINK primitive -> default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
  };
};

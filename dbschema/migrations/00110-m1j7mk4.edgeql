CREATE MIGRATION m1j7mk4ymlihgymuth6thzvf6bw574ku4edladvmoxq4qmns2bk4ra
    ONTO m1ky4upeyumkooxu7iyxt2olkgqttd2uqxjvxk6nusudb7jhaey6aa
{
  ALTER TYPE design::Component {
      CREATE LINK category: default::Category {
          ON TARGET DELETE ALLOW;
      };
  };
};

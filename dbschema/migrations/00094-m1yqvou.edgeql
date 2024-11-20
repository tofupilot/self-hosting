CREATE MIGRATION m1yqvoumqfewx3dn2kilibqhj4woqm4m7piwcwy5nm4hlfqjf76mga
    ONTO m137jkwdp7d7lfbvnbaydtcicdkoirhn3bxpwsdftn34iua3ezfpfq
{
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY IAllowServerToSelectOrganizationsForMiddlewareCheck;
  };
};

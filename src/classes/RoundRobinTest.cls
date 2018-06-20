/*
** Class: RoundRobinTest
** Created by OpFocus (Veena Sundara-Heragu) on 6/19/18
** Description: Test class for RoundRobin
*/
@isTest
public class RoundRobinTest
{

    @testSetup static void buildData()
    {
    }

    //test methods

    static testMethod void myTest1()
    {
        Group g = new Group(Name = 'Unit Test Group');
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert g;
        }

        User[] lstUser = [Select Id from User Where IsActive = true AND UserType = 'Standard' Order By Name LIMIT 10];

        // add 2 members to each group
        List<GroupMember>lstGM = new List<GroupMember>();
        for (User u : lstUser)
        {
            lstGM.add(new GroupMember(GroupId = g.Id,
                    UserOrGroupId = u.Id));
        }
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert lstGM;
        }

        RoundRobin rr =new RoundRobin();
        rr.getNextUser(g.Name);
        rr.getNextUser(g.Name);
        system.assertEquals(10, rr.getGroupMembers(g.Name).size());
    }

}
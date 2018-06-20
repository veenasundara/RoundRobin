/* Class:       RoundRobin
** Created by:  OpFocus (Veena Sundara-Heragu) on 02/14/2017
** Description: handles round robin assignment to members of public groups
*/
public class RoundRobin 
{
    private Map<String, RoundRobinLastAssignment__c> mapLastAssignedByGroupName = new Map<String, RoundRobinLastAssignment__c>();
    private Map<String, List<User>> mapMembersByGroupName = new Map<String, List<User>>();

	public Id getNextUser(String groupName)
	{
		getLastAssignedUsers();

		List<User> lstUser = getGroupMembers(groupName);
		if(lstUser == null || lstUser.isEmpty())
		{
			return null;
		}

		RoundRobinLastAssignment__c lastAssigned = mapLastAssignedByGroupName.get(groupName);
        // If this is the first time we are assigning from this group, craete a new custom setting
        // record and use the first user from our list
        if(lastAssigned == null)
        {
            lastAssigned = new RoundRobinLastAssignment__c(Name = 'Group_' + String.valueOf(Math.random()).substring(2, 6),
			                                                Last_Assigned_User_Id__c = lstUser[0].Id,
			                                                Last_Assigned_User_Name__c = lstUser[0].Name,
			                                                Group_Name__c = groupName);
            insert lastAssigned;
            mapLastAssignedByGroupName.put(groupName, lastAssigned);
            return lastAssigned.Last_Assigned_User_Id__c;
        }// first time assigning from this Group

        // not first time so get next user to assign to
        Integer index = 0;
        Integer newIndex = 0;
        for(User u : lstUser)
        {
            if(u.Name == lastAssigned.Last_Assigned_User_Name__c) // found last used user, get next one
            {
                newIndex = index + 1 == lstUser.size() ? 0 : index + 1;
                break;
            }
            index++;
        }

        // update custom setting with new user and the map
        lastAssigned.Last_Assigned_User_Id__c = lstUser[newIndex].Id;
        lastAssigned.Last_Assigned_User_Name__c = lstUser[newIndex].Name;
        update lastAssigned;
        mapLastAssignedByGroupName.put(groupName, lastAssigned);

        return(lastAssigned.Last_Assigned_User_Id__c);
	}

	private void getLastAssignedUsers()
	{
		if(!mapLastAssignedByGroupName.isEmpty())
		{
			return;
		}
        // get last assigned users for all queues
        for(RoundRobinLastAssignment__c rr : RoundRobinLastAssignment__c.getAll().values())
        {
            mapLastAssignedByGroupName.put(rr.Group_Name__c, rr);
        }
	}

	public List<User> getGroupMembers(String groupName)
	{
		if(mapMembersByGroupName.containsKey(groupName))
		{
			return mapMembersByGroupName.get(groupName);
		}

		Set<Id> setUserId = getGroupUserIds(groupName);

		List<User> lstUser = [Select Id, Name from User where Id in :setUserId and isActive = true
								order by Name];
		mapMembersByGroupName.put(groupName, lstUser);

		return lstUser;
	}

	private Set<Id> getGroupUserIds(String groupName)
	{
		Set<Id> setUserId = new Set<Id>();
		Set<Id> setGroupId = new Set<Id>();
        for(GroupMember gm : [Select GroupId, UserOrGroupId From GroupMember where Group.Name = :groupName
        		and Group.Type = 'Regular'])
        {
            if(gm.UserOrGroupId.getSObjectType() == User.getSObjectType())
            {
            	setUserId.add(gm.UserOrGroupId);
            }
            if(gm.UserOrGroupId.getSObjectType() == Group.getSObjectType())
            {
            	setGroupId.add(gm.UserOrGroupId);
            }
        }

        if(!setGroupId.isEmpty())
        {
        	setUserId.addAll(getGroupUserIds(setGroupId));
        }

        return setUserId;
	}

	private Set<Id> getGroupUserIds(Set<Id> setGroupId)
	{
		Set<Id> setUserId = new Set<Id>();
		Set<Id> setChildGroupId = new Set<Id>();
        for(GroupMember gm : [Select GroupId, UserOrGroupId From GroupMember where Id in :setGroupId])
        {
            if(gm.UserOrGroupId.getSObjectType() == User.getSObjectType())
            {
            	setUserId.add(gm.UserOrGroupId);
            }
            if(gm.UserOrGroupId.getSObjectType() == Group.getSObjectType())
            {
            	setChildGroupId.add(gm.UserOrGroupId);
            }
        }

        if(!setChildGroupId.isEmpty())
        {
        	setUserId.addAll(getGroupUserIds(setChildGroupId));
        }
        return setUserId;
	}	
}
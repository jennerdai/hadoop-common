<%
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file 
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
%>
<%@ page
  contentType="text/html; charset=UTF-8"
  import="javax.servlet.http.*"
  import="java.io.*"
  import="java.util.*"
  import="org.apache.hadoop.mapred.*"
  import="org.apache.hadoop.fs.*"
  import="org.apache.hadoop.util.*"
  import="java.text.*"
  import="org.apache.hadoop.mapred.JobHistory.*" 
%>
<%! private static SimpleDateFormat dateFormat = new SimpleDateFormat("d/MM HH:mm:ss") ;
    private static final long serialVersionUID = 1L;
%>

<%
  String jobid = request.getParameter("jobid");
  String attemptid = request.getParameter("attemptid");
  String taskid = request.getParameter("taskid");
  String logFile = request.getParameter("logFile");
  String encodedLogFileName = 
    JobHistory.JobInfo.encodeJobHistoryFilePath(logFile);

  Format decimal = new DecimalFormat();

  FileSystem fs = (FileSystem) application.getAttribute("fileSys");
  JobHistory.JobInfo job = JSPUtil.getJobInfo(request, fs);

  JobHistory.Task task = job.getAllTasks().get(taskid);
  JobHistory.TaskAttempt attempt = task.getTaskAttempts().get(attemptid);

  Counters counters = 
    Counters.fromEscapedCompactString(attempt.get(Keys.COUNTERS));
%>

<html>
  <head>
    <title>Counters for <%=attemptid%></title>
  </head>
<body>
<h1>Counters for <%=attemptid%></h1>

<hr>

<%
  if (counters == null) {
%>
    <h3>No counter information found for this attempt</h3>
<%
  } else {    
%>
    <table>
<%
      for (String groupName : counters.getGroupNames()) {
        Counters.Group group = counters.getGroup(groupName);
        String displayGroupName = group.getDisplayName();
%>
        <tr>
          <td colspan="3"><br/><b><%=displayGroupName%></b></td>
        </tr>
<%
        Iterator<Counters.Counter> ctrItr = group.iterator();
        while(ctrItr.hasNext()) {
          Counters.Counter counter = ctrItr.next();
          String displayCounterName = counter.getDisplayName();
          long value = counter.getCounter();
%>
          <tr>
            <td width="50"></td>
            <td><%=displayCounterName%></td>
            <td align="right"><%=decimal.format(value)%></td>
          </tr>
<%
        }
      }
%>
    </table>
<%
  }
%>

<hr>
<a href="jobdetailshistory.jsp?jobid=<%=jobid%>&logFile=<%=encodedLogFileName%>">Go back to the job</a><br>
<a href="jobtracker.jsp">Go back to JobTracker</a><br>
<%
out.println(ServletUtil.htmlFooter());
%>

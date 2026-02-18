import { useParams, useNavigate } from "react-router-dom";

function ProjectDetails() {
  const { projectId } = useParams();
  const navigate = useNavigate();

  return (
    <div style={{ padding: "2rem" }}>
      <h2>Project Details: {projectId}</h2>
      <p>This is a placeholder for the project details page.</p>
      <button onClick={() => navigate("/projects")}>Back to Projects</button>
    </div>
  );
}

export default ProjectDetails;
